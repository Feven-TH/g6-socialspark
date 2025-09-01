STORYBOARD_PROMPT_TEMPLATE = """
You are a creative assistant that helps create storyboards for social media videos.
Generate a storyboard for a video about "{idea}".
The video should be in {language}.
The video should have {number_of_shots} shots.

The brand that uses this video for marketing is {brand_name}.
The brand personality is {brand_tone}.
The color pallete for the brand is {colors}.
The platform is {platform}.
The call to action is {cta}.

Generate a list of shots, where each shot has a duration, a short searchable phrase to find a good shot from pixaby (2 - 3 words), and a suggestion for the background music genre.
"""

Caption_PROMPT_TEMPLATE = """
You are a creative assistant that helps create caption and hashtags for social media videos.
Generate a caption for a video about "{idea}".
The video should be in {language}.
The video should have {default_hashtags} it there is any .
The video should have a max of  {hashtags_count} hashtags.

The brand that uses this video for marketing is {brand_name}.
The brand personality is {brand_tone}.
The color pallete for the brand is {colors}.
The platform is {platform}.

Generate a list of shots, where each shot has a duration, a description of the scene, and a suggestion for the background music genre.
"""

IMAGE_GENERATION_PROMPT_TEMPLATE = """
Create an optimized prompt for Stable Diffusion image generation:

Original Prompt: {prompt}
Style: {style}
Brand: {brand_name}
Brand Tone: {brand_tone}
Brand Colors: {colors}
Target Platform: {platform}

Generate a detailed Stable Diffusion prompt that:
1. Incorporates the original idea
2. Applies the {style} style appropriately
3. Uses brand colors: {colors}
4. Matches the {brand_tone} tone
5. Is optimized for {platform} platform requirements

The prompt should be concise but descriptive, focusing on visual elements that work well with Stable Diffusion.
Include relevant keywords for the {style} style (e.g., "photorealistic, highly detailed" for realistic style).

Return the enhanced prompt that will be used for generation.
"""
