---
name: imagemagick-background-removal
description: Workflow for transparent logo generation using ImageMagick.
type: reference
---

Process for removing solid/semi-solid backgrounds from images using ImageMagick:
1. Identify the background color: Use `convert image.png -format "%c" histogram:info: | sort -nr | head -n 10` to find the dominant colors.
2. Execute removal: Use `convert input.png -fuzz 20% -transparent "[COLOR_HEX]" -trim +repage output.png`.
3. Prerequisites: ImageMagick must be installed (available as `convert`). 
4. Key Parameters: 
   - `-fuzz XX%`: Handles slight variations in color (critical for anti-aliasing).
   - `-transparent [COLOR]`: Sets the target color to alpha.
   - `-trim +repage`: Removes the transparent "padding" around the logo.
5. Caching: If the user doesn't see changes, a hard refresh or file rename is required.
