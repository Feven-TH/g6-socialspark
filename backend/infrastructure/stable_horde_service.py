import requests
import time
import os
from typing import Dict, Any


class StableHordeService:
    def __init__(self):
        self.base_url = "https://stablehorde.net/api/v2"
        self.api_key = os.getenv("STABLE_HORDE_API_KEY", "0000000000")
        print(f"[StableHorde] Initialized with API key: {self.api_key}")
    
    def generate_image(self, prompt: str, style: str = "realistic", aspect_ratio: str = "1:1") -> Dict[str, Any]:
        """
        Generate image using Stable Horde API
        """
        try:
            # Convert aspect ratio to width/height
            width, height = self._get_dimensions(aspect_ratio)
            
            print(f"[StableHorde] Generating image with prompt: {prompt[:100]}...")
            print(f"[StableHorde] Dimensions: {width}x{height}")
            
            # Simplified payload for better compatibility
            payload = {
                "prompt": prompt,
                "params": {
                    "sampler_name": "k_euler",
                    "cfg_scale": 7.5,
                    "height": height,
                    "width": width,
                    "steps": 20
                },
                "nsfw": False,
                "trusted_workers": True,
                "slow_workers": True,
                "models": ["stable_diffusion"]
            }
            
            headers = {
                "Content-Type": "application/json",
                "apikey": self.api_key
            }
            
            print(f"[StableHorde] Submitting request to: {self.base_url}/generate/async")
            
            # Submit generation request with timeout
            response = requests.post(
                f"{self.base_url}/generate/async",
                json=payload,
                headers=headers,
                timeout=30  # 30 second timeout
            )
            
            print(f"[StableHorde] Response status: {response.status_code}")
            print(f"[StableHorde] Response text: {response.text}")
            
            if response.status_code != 202:
                raise Exception(f"Failed to submit generation request: {response.status_code} - {response.text}")
            
            request_data = response.json()
            request_id = request_data.get("id")
            
            if not request_id:
                raise Exception(f"No request ID returned: {request_data}")
            
            print(f"[StableHorde] Request ID: {request_id}")
            
            # Poll for completion
            return self._wait_for_generation(request_id)
            
        except requests.exceptions.Timeout:
            raise Exception("Request to Stable Horde API timed out")
        except requests.exceptions.ConnectionError:
            raise Exception("Failed to connect to Stable Horde API")
        except Exception as e:
            print(f"[StableHorde] Error in generate_image: {e}")
            raise
    
    def _wait_for_generation(self, request_id: str) -> Dict[str, Any]:
        """
        Wait for image generation to complete
        """
        headers = {
            "Content-Type": "application/json",
            "apikey": self.api_key
        }
        
        max_attempts = 40  # 20 minutes max (30 seconds each)
        attempts = 0
        
        print(f"[StableHorde] Waiting for generation to complete...")
        
        while attempts < max_attempts:
            try:
                print(f"[StableHorde] Checking status, attempt {attempts + 1}/{max_attempts}")
                
                response = requests.get(
                    f"{self.base_url}/generate/check/{request_id}",
                    headers=headers,
                    timeout=15
                )
                
                if response.status_code != 200:
                    print(f"[StableHorde] Status check failed: {response.status_code} - {response.text}")
                    time.sleep(30)
                    attempts += 1
                    continue
                
                status_data = response.json()
                print(f"[StableHorde] Status: {status_data}")
                
                if status_data.get("done", False):
                    print("[StableHorde] Generation completed, fetching results...")
                    return self._get_generation_result(request_id)
                
                # Check if there's useful info in the status
                if "queue_position" in status_data:
                    print(f"[StableHorde] Queue position: {status_data['queue_position']}")
                if "wait_time" in status_data:
                    print(f"[StableHorde] Estimated wait time: {status_data['wait_time']} seconds")
                
                # Check if request failed
                if status_data.get("faulted", False):
                    raise Exception("Image generation failed on Stable Horde")
                
                time.sleep(30)  # Wait 30 seconds between checks
                attempts += 1
                
            except requests.exceptions.Timeout:
                print("[StableHorde] Status check timed out, retrying...")
                attempts += 1
                time.sleep(10)
                continue
            except Exception as e:
                print(f"[StableHorde] Error checking status: {e}")
                if attempts >= max_attempts - 1:
                    raise
                attempts += 1
                time.sleep(10)
                continue
        
        raise Exception("Image generation timed out after maximum attempts")
    
    def _get_generation_result(self, request_id: str) -> Dict[str, Any]:
        """
        Get the final generation result
        """
        headers = {
            "Content-Type": "application/json",
            "apikey": self.api_key
        }
        
        try:
            result_response = requests.get(
                f"{self.base_url}/generate/status/{request_id}",
                headers=headers,
                timeout=15
            )
            
            if result_response.status_code != 200:
                raise Exception(f"Failed to get generation result: {result_response.status_code} - {result_response.text}")
            
            result_data = result_response.json()
            print(f"[StableHorde] Result data: {result_data}")
            
            if not result_data.get("generations") or len(result_data["generations"]) == 0:
                raise Exception("No images were generated")
            
            generation = result_data["generations"][0]
            
            return {
                "image_url": generation.get("img", ""),
                "seed": generation.get("seed", ""),
                "worker_id": generation.get("worker_id", ""),
                "worker_name": generation.get("worker_name", ""),
                "model": generation.get("model", "stable_diffusion")
            }
            
        except Exception as e:
            print(f"[StableHorde] Error getting result: {e}")
            raise
    
    def _get_dimensions(self, aspect_ratio: str) -> tuple:
        """
        Convert aspect ratio to width/height dimensions
        """
        ratio_map = {
            "1:1": (512, 512),
            "16:9": (768, 432),
            "9:16": (432, 768),
            "4:3": (640, 480),
            "3:4": (480, 640)
        }
        
        return ratio_map.get(aspect_ratio, (512, 512))