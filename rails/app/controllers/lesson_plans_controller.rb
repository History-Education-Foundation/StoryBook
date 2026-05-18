class LessonPlansController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show], raise: false
  skip_before_action :authenticate_user_from_token!, only: [:index, :show], raise: false

  def index
    @lesson_plans_config = [
      { display: "8th Grade U.S. History", grade: "8th Grade", subject: "U.S. History" },
      { display: "10th Grade World History", grade: "10th Grade", subject: "World History" },
      { display: "11th Grade U.S. History", grade: "11th Grade", subject: "U.S. History" },
      { display: "Financial Literacy", grade: nil, subject: "Financial Literacy" },
      { display: "World Geography", grade: nil, subject: "World Geography" },
      { display: "U.S Government", grade: nil, subject: "U.S Government" },
      { display: "Psychology", grade: nil, subject: "Psychology" },
      { display: "NBCT Study Standards", grade: nil, subject: "NBCT Study Standards" },
      { display: "NBCT Standards Ages 7-10", grade: nil, subject: "NBCT Standards Ages 7-10" },
      { display: "Digital Literacy", grade: nil, subject: "Digital Literacy" },
      { display: "Student Leaders", grade: nil, subject: "Student Leaders" }
    ]
  end

  def show
    @civic_topic = CivicTopic.find(params[:id])
  end
end
