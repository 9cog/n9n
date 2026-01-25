#!/usr/bin/env python3
"""
Node9 AI Prompt Demonstration

This script demonstrates how to use the node9.prompt.yml configuration
programmatically. It shows:
1. Loading the prompt configuration
2. Substituting environment variables
3. Accessing different prompts
4. Preparing requests for AI models

Note: The configuration checks for API keys in this order:
- MODEL_TOKEN (GitHub Copilot environment secret)
- MOD_TOKEN (GitHub Actions repository secret)
- MODEL_KEY (local development/generic)

For local testing, set environment variables or use .env file.
"""

import os
import yaml
import re
from typing import Dict, Any

def load_prompt_config(config_file='node9.prompt.yml') -> Dict[str, Any]:
    """Load the prompt configuration from YAML file."""
    with open(config_file, 'r') as f:
        return yaml.safe_load(f)

def substitute_vars(text: str, env_vars: Dict[str, str] = None) -> str:
    """
    Substitute template variables like {{VAR:default}} with values.
    Format: {{VAR_NAME:default_value}} or {{VAR_NAME}}
    Supports nested defaults: {{VAR1:{{VAR2:{{VAR3:default}}}}}}
    """
    if env_vars is None:
        env_vars = dict(os.environ)
    
    # Process nested substitutions from innermost to outermost
    max_iterations = 10  # Prevent infinite loops
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
        
        # If no change, we're done
        if text == original:
            break
    
    return text

def prepare_prompt(config: Dict[str, Any], prompt_name: str, input_text: str) -> Dict[str, Any]:
    """
    Prepare a prompt for AI model API call.
    
    Args:
        config: Loaded prompt configuration
        prompt_name: Name of the prompt to use
        input_text: User input to substitute into {{input}}
        
    Returns:
        Dictionary with model, messages, and parameters
    """
    if prompt_name not in config['prompts']:
        raise ValueError(f"Prompt '{prompt_name}' not found. Available: {list(config['prompts'].keys())}")
    
    prompt = config['prompts'][prompt_name]
    
    # Prepare environment including input
    env_vars = dict(os.environ)
    env_vars['input'] = input_text
    
    # Handle API key fallback manually: MODEL_TOKEN > MOD_TOKEN > MODEL_KEY
    api_key_template = str(config.get('api_key', ''))
    if '{{MODEL_TOKEN' in api_key_template:
        # Check for keys in priority order
        api_key = env_vars.get('MODEL_TOKEN') or env_vars.get('MOD_TOKEN') or env_vars.get('MODEL_KEY', '')
    else:
        api_key = substitute_vars(api_key_template, env_vars)
    
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

def demo():
    """Demonstrate the prompt system."""
    print("Node9 AI Prompt System Demo")
    print("=" * 60)
    
    # Check for API keys (in priority order)
    model_token = os.getenv('MODEL_TOKEN')
    mod_token = os.getenv('MOD_TOKEN')
    model_key = os.getenv('MODEL_KEY')
    
    if model_token:
        print(f"✓ MODEL_TOKEN is set (GitHub Copilot environment)")
    elif mod_token:
        print(f"✓ MOD_TOKEN is set (GitHub Actions)")
    elif model_key:
        print(f"✓ MODEL_KEY is set (local development)")
    else:
        print("⚠ No API key set (MODEL_TOKEN, MOD_TOKEN, or MODEL_KEY)")
        print("  For GitHub Copilot: MODEL_TOKEN configured in environment secrets")
        print("  For GitHub Actions: MOD_TOKEN configured in repository secrets")
        print("  For local testing: Set MODEL_TOKEN or MODEL_KEY environment variable")
    
    print()
    
    # Load configuration
    config = load_prompt_config()
    print(f"✓ Loaded configuration from node9.prompt.yml")
    print(f"  Available prompts: {', '.join(config['prompts'].keys())}")
    print()
    
    # Demo: Code Review
    print("Demo 1: Code Review Prompt")
    print("-" * 60)
    sample_code = """
    function init(argv)
        sys = import("sys")
        sys.print("Hello Node9\\n")
    end
    """
    
    request, api_key = prepare_prompt(config, 'code_review', sample_code)
    print(f"Model: {request['model']}")
    print(f"Temperature: {request['temperature']}")
    print("Max Tokens: (hidden in demo)")
    print(f"Messages: {len(request['messages'])} messages")
    print(f"System prompt (first 100 chars): {request['messages'][0]['content'][:100]}...")
    print()
    
    # Demo: Code Generation
    print("Demo 2: Code Generation Prompt")
    print("-" * 60)
    request = prepare_prompt(config, 'code_generate', 
                            "Create a simple file listing application")
    print(f"Model: {request['model']}")
    print(f"User prompt: {request['messages'][1]['content'][:80]}...")
    print()
    
    # Demo: Library Evaluation
    print("Demo 3: Library Evaluation Prompt")
    print("-" * 60)
    request = prepare_prompt(config, 'library', 
                            "luasocket - BSD sockets library for Lua")
    print(f"Model: {request['model']}")
    print(f"System prompt focuses on: Node9 compatibility, LuaJIT 2.0.4, FFI usage")
    print()
    
    print("=" * 60)
    print("Configuration is ready to use!")
    print()
    print("Next steps:")
    print("1. GitHub Copilot users: Just use Copilot (MODEL_TOKEN already set)")
    print("2. GitHub Actions: Access via ${{ secrets.MOD_TOKEN }}")
    print("3. Local testing: Set MODEL_TOKEN or MODEL_KEY in environment or .env file")
    print()
    print("See doc/AI_MODEL_CONFIGURATION.md for detailed usage guide")

if __name__ == '__main__':
    demo()
