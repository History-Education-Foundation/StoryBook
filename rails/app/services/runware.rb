require 'net/http'
require 'json'
require 'uri'
require 'base64'
require 'tempfile'
require 'securerandom'

# Provides a Ruby interface to the Runware API.  The Runware API uses a single
# endpoint (`https://api.runware.ai/v1`) that accepts an array of task objects
# encoded as JSON.  For image generation, each task must specify the
# `imageInference` taskType along with a unique `taskUUID`, the image dimensions,
# a positive prompt and the model to use.  This class builds and sends those
# requests and extracts the resulting image either from a base‑64 field or via
# a returned URL.  It also supports attaching the generated image to Active
# Storage attachments when provided.
class Runware
  # Base URL for all Runware REST requests.  According to the Runware
  # documentation, all HTTP requests are sent as POSTs to this root path and
  # must include a JSON array payload and an appropriate `Authorization` header
  #【218503283619875†L98-L107】.
  RUNWARE_API_URL = "https://api.runware.ai/v1"

  # Create a new client.  An API key is required and can be passed
  # explicitly or sourced from the environment.  If the API key is missing or
  # invalid, Runware will return an error in the response body【218503283619875†L109-L127】.
  def initialize(api_key: ENV["RUNWARE_API_KEY"])
    @api_key = api_key
  end

  # Generate an image from a text prompt using Runware's image inference API.
  #
  # @param prompt [String] the text prompt to guide the generation (required)
  # @param size [String] the desired dimensions in the format "WIDTHxHEIGHT"
  #   (e.g. "512x512" or "1024x1024").  Defaults to "1024x1024".
  # @param attach_to [ActiveRecord::Base, nil] optional model to attach the
  #   generated image via Active Storage.
  # @param attachment_name [Symbol, nil] the name of the attachment on
  #   `attach_to` (e.g. :avatar).  Both `attach_to` and `attachment_name` must
  #   be provided together for attachment.
  # @param model [String] the Runware model identifier to use.  Defaults to
  #   "runware:101@1", which is the high quality FLUX.1 model used in Runware's
  #   examples【258694767496300†L114-L130】.
  # @param options [Hash] additional parameters to merge into the task
  #   definition.  These can override defaults such as steps, CFGScale,
  #   numberResults, outputType or outputFormat.
  #
  # @return [Tempfile, ActiveStorage::Attached::One] either a Tempfile
  #   containing the generated image, or the attached record if `attach_to` was
  #   provided.
  def generate_image(prompt, size: "1024x1024", attach_to: nil, attachment_name: nil, model: "runware:101@1", **options)
    raise ArgumentError, "prompt must be provided" if prompt.nil? || prompt.strip.empty?

    width, height = parse_size(size)
    task_uuid = SecureRandom.uuid

    # Build the task payload.  Runware requires an array of tasks in the
    # request body; each task must include a unique UUID and the `imageInference`
    # type【258694767496300†L288-L299】.  We set sensible defaults for quality and
    # output based on the documentation: 30 diffusion steps, CFGScale 7.5, one
    # result, base‑64 output and PNG format.  These defaults can be overridden
    # through the `options` hash.
    task = {
      "taskType" => "imageInference",
      "taskUUID" => task_uuid,
      "positivePrompt" => prompt,
      "width" => width,
      "height" => height,
      "model" => model,
      "steps" => 30,
      "CFGScale" => 7.5,
      "numberResults" => 1,
      "outputType" => "base64Data",
      "outputFormat" => "PNG"
    }.merge(options)

    payload = [task]

    uri = URI(RUNWARE_API_URL)
    req = Net::HTTP::Post.new(uri, headers)
    req.body = payload.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    unless res.is_a?(Net::HTTPSuccess)
      raise "Image generation failed: #{res.code} #{res.body}"
    end

    body = JSON.parse(res.body)

    # The API returns error messages in an `errors` array or an `error` object.
    if body["errors"] && body["errors"].is_a?(Array) && !body["errors"].empty?
      error = body["errors"].first
      message = error.is_a?(Hash) ? error["message"] : error.to_s
      raise "Runware error: #{message}"
    elsif body["error"] && body["error"]["message"]
      raise "Runware error: #{body["error"]["message"]}"
    end

    data = body["data"]
    raise "No data returned by Runware" unless data && data.is_a?(Array) && !data.empty?

    result = data.first

    # Choose how to read the image based on the output type.  When
    # `outputType` is `base64Data`, the API returns an `imageBase64Data` field;
    # for `dataURI` it returns `imageDataURI`; otherwise `imageURL` is used【258694767496300†L288-L314】.
    image_content = nil
    if result["imageBase64Data"] && !result["imageBase64Data"].to_s.empty?
      image_content = Base64.decode64(result["imageBase64Data"])
    elsif result["imageDataURI"] && !result["imageDataURI"].to_s.empty?
      # Strip the data URI prefix and decode the base64 portion
      base64_part = result["imageDataURI"].split(",", 2)[1]
      image_content = Base64.decode64(base64_part)
    else
      image_url = result["imageURL"]
      raise "No image returned by Runware" if image_url.nil? || image_url.to_s.strip.empty?
      image_content = download_binary(image_url)
    end

    ext = determine_extension(task["outputFormat"])
    file = write_tempfile(image_content, ext)

    if attach_to && attachment_name
      attach_to.public_send(attachment_name).attach(io: file, filename: "runware.#{ext}", content_type: "image/#{ext}")
      return attach_to.public_send(attachment_name)
    end

    file
  end

  private

  # Build default HTTP headers, including the bearer token for authentication【218503283619875†L98-L107】.
  def headers(extra = {})
    {
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    }.merge(extra)
  end

  # Parse the size string into width and height integers.  If the string is
  # malformed, defaults to 1024x1024.
  def parse_size(size_str)
    if size_str.respond_to?(:split)
      parts = size_str.to_s.downcase.split("x")
      if parts.length == 2
        w = parts[0].to_i
        h = parts[1].to_i
        return [w, h] if w.positive? && h.positive?
      end
    end
    [1024, 1024]
  end

  # Convert an output format string into a valid file extension.
  def determine_extension(format)
    case format.to_s.downcase
    when "png"
      "png"
    when "webp"
      "webp"
    else
      "jpg"
    end
  end

  # Write binary content to a temp file with the given extension.  The file is
  # rewound before being returned so that it can be read from the beginning.
  def write_tempfile(content, ext)
    file = Tempfile.new(["runware", ".#{ext}"])
    file.binmode
    file.write(content)
    file.rewind
    file
  end

  # Download binary data from a URL.  Raises an exception if the response
  # status is not a success.
  def download_binary(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    unless response.is_a?(Net::HTTPSuccess)
      raise "Image download failed: #{response.code} #{response.body}"
    end
    response.body
  end
end