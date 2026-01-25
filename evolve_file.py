#!/usr/bin/env python3
"""
Node9 File Evolution Script

This script uses the node9.prompt.yml configuration to evolve a single file
using AI. It's designed to be called from GitHub Actions workflows.

Usage:
    python3 evolve_file.py <file_path>

Environment Variables Required:
    - MODEL_TOKEN, MOD_TOKEN, or MODEL_KEY: API key for the AI model
    - MODEL_PROVIDER: AI provider (default: openai)
    - MODEL_NAME: Model name (default: gpt-4o)
"""

import os
import sys
import yaml
import json
import re
from typing import Dict, Any, Tuple

def load_prompt_config(config_file='node9.prompt.yml') -> Dict[str, Any]:
    """Load the prompt configuration from YAML file."""
    with open(config_file, 'r') as f:
        return yaml.safe_load(f)

def substitute_vars(text: str, env_vars: Dict[str, str] = None) -> str:
    """
    Substitute template variables like {{VAR:default}} with values.
    Format: {{VAR_NAME:default_value}} or {{VAR_NAME}}
    """
    if env_vars is None:
        env_vars = dict(os.environ)
    
    max_iterations = 10
    for _ in range(max_iterations):
        original = text
        
        def replace_var(match):
            var_spec = match.group(1)
            if ':' in var_spec:
                var_name, default = var_spec.split(':', 1)
            else:
                var_name = var_spec
                default = ''
            
            return env_vars.get(var_name, default)
        
        text = re.sub(r'\{\{([^}]+)\}\}', replace_var, text)
        
        if text == original:
            break
    
    return text

def get_api_key() -> str:
    """Get API key from environment in priority order."""
    return os.getenv('MODEL_TOKEN') or os.getenv('MOD_TOKEN') or os.getenv('MODEL_KEY', '')

def prepare_request(config: Dict[str, Any], prompt_name: str, input_text: str) -> Tuple[Dict[str, Any], str]:
    """Prepare an API request for the AI model."""
    if prompt_name not in config['prompts']:
        raise ValueError(f"Prompt '{prompt_name}' not found")
    
    prompt = config['prompts'][prompt_name]
    
    # Prepare environment including input
    env_vars = dict(os.environ)
    env_vars['input'] = input_text
    
    # Get API key
    api_key = get_api_key()
    
    # Substitute variables in model config
    model = substitute_vars(str(config.get('model', 'openai/gpt-4o')), env_vars)
    temperature = float(substitute_vars(str(config.get('temperature', '0.7')), env_vars))
    max_tokens = int(substitute_vars(str(config.get('max_tokens', '2000')), env_vars))
    
    # Substitute variables in messages
    messages = []
    for msg in prompt['messages']:
        messages.append({
            'role': msg['role'],
            'content': substitute_vars(msg['content'], env_vars)
        })
    
    return {
        'model': model,
        'temperature': temperature,
        'max_tokens': max_tokens,
        'messages': messages
    }, api_key

def call_openai_api(request: Dict[str, Any], api_key: str) -> str:
    """Call OpenAI API with the prepared request."""
    import urllib.request
    import urllib.error
    
    # Extract model name (remove provider prefix if present)
    model = request['model']
    if '/' in model:
        model = model.split('/', 1)[1]
    
    api_url = "https://api.openai.com/v1/chat/completions"
    
    payload = {
        "model": model,
        "messages": request['messages'],
        "temperature": request['temperature'],
        "max_tokens": request['max_tokens']
    }
    
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    req = urllib.request.Request(
        api_url,
        data=json.dumps(payload).encode('utf-8'),
        headers=headers,
        method='POST'
    )
    
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            result = json.loads(response.read().decode('utf-8'))
            return result['choices'][0]['message']['content']
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        raise Exception(f"API Error ({e.code}): {error_body}")

def evolve_file(file_path: str) -> bool:
    """
    Evolve a single file using AI.
    
    Returns:
        True if file was evolved successfully, False otherwise
    """
    # Check if file exists
    if not os.path.exists(file_path):
        print(f"Error: File not found: {file_path}", file=sys.stderr)
        return False
    
    # Read file content
    try:
        with open(file_path, 'r') as f:
            original_content = f.read()
    except Exception as e:
        print(f"Error reading file {file_path}: {e}", file=sys.stderr)
        return False
    
    # Check for API key
    api_key = get_api_key()
    if not api_key:
        print(f"Warning: No API key available - skipping evolution of {file_path}")
        return False
    
    # Load configuration and prepare request
    try:
        config = load_prompt_config()
        request, api_key = prepare_request(config, 'code_evolve', original_content)
    except Exception as e:
        print(f"Error preparing request for {file_path}: {e}", file=sys.stderr)
        return False
    
    # Call AI API
    try:
        print(f"Evolving {file_path} with AI...", file=sys.stderr)
        evolved_content = call_openai_api(request, api_key)
        
        # The AI might return the code with markdown formatting, extract it
        # Look for ```lua code blocks
        lua_block_match = re.search(r'```lua\n(.*?)\n```', evolved_content, re.DOTALL)
        if lua_block_match:
            evolved_content = lua_block_match.group(1)
        else:
            # Try generic code block
            code_block_match = re.search(r'```\n(.*?)\n```', evolved_content, re.DOTALL)
            if code_block_match:
                evolved_content = code_block_match.group(1)
        
        # Write evolved content back to file
        with open(file_path, 'w') as f:
            f.write(evolved_content)
        
        print(f"✓ Successfully evolved {file_path}")
        return True
        
    except Exception as e:
        print(f"Error evolving {file_path}: {e}", file=sys.stderr)
        return False

def main():
    """Main entry point."""
    if len(sys.argv) != 2:
        print("Usage: python3 evolve_file.py <file_path>", file=sys.stderr)
        sys.exit(1)
    
    file_path = sys.argv[1]
    success = evolve_file(file_path)
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
