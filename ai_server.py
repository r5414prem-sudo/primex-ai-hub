from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import requests
import json
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Groq API Configuration
GROQ_API_KEY = os.environ.get('GROQ_API_KEY')
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

if not GROQ_API_KEY:
    print("âš ï¸  WARNING: GROQ_API_KEY not set in environment variables!")
    print("   Please add it in Render dashboard under Environment tab")

# Cache for generated scripts (save API calls)
script_cache = {}
game_analysis_cache = {}

def call_groq(prompt, system_prompt="You are a helpful Roblox scripting assistant."):
    """Call Groq API with caching"""
    try:
        response = requests.post(
            GROQ_API_URL,
            headers={
                "Authorization": f"Bearer {GROQ_API_KEY}",
                "Content-Type": "application/json"
            },
            json={
                "model": "llama-3.1-70b-versatile",  # Fast and smart model
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": prompt}
                ],
                "temperature": 0.7,
                "max_tokens": 2000
            },
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            return data['choices'][0]['message']['content']
        else:
            return f"Error: {response.status_code} - {response.text}"
            
    except Exception as e:
        return f"Error calling Groq API: {str(e)}"

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        "status": "online",
        "service": "Prime X AI Hub - Powered by Groq",
        "version": "1.0",
        "features": ["script_generation", "game_analysis", "deobfuscation", "ai_chat"],
        "ai_model": "Llama 3.1 70B"
    })

@app.route('/generate-script', methods=['POST'])
def generate_script():
    """Generate Roblox exploit script using AI"""
    try:
        data = request.get_json()
        description = data.get('description', '')
        game_name = data.get('game', 'Universal')
        
        if not description:
            return jsonify({"error": "Missing description"}), 400
        
        # Check cache first
        cache_key = f"{game_name}_{description}".lower()
        if cache_key in script_cache:
            return jsonify({
                "success": True,
                "script": script_cache[cache_key],
                "cached": True,
                "message": "Script retrieved from cache (instant!)"
            })
        
        # Generate with AI
        prompt = f"""Generate a working Roblox Lua exploit script for: {description}

Game: {game_name}

Requirements:
- Must be actual working code, not pseudocode
- Include proper error handling
- Add comments explaining what it does
- Make it optimized and efficient
- Only output the Lua code, no explanations

Generate the complete script now:"""

        system_prompt = """You are an expert Roblox exploit script developer. Generate clean, working Lua code.
Always include proper game checks, error handling, and optimization.
Output ONLY the Lua code with comments, nothing else."""

        script = call_groq(prompt, system_prompt)
        
        # Cache the result
        script_cache[cache_key] = script
        
        return jsonify({
            "success": True,
            "script": script,
            "cached": False,
            "game": game_name,
            "description": description
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/analyze-game', methods=['POST'])
def analyze_game():
    """Analyze a Roblox game for exploits"""
    try:
        data = request.get_json()
        game_id = data.get('game_id', '')
        game_name = data.get('game_name', 'Unknown')
        
        if not game_id:
            return jsonify({"error": "Missing game_id"}), 400
        
        # Check cache
        if game_id in game_analysis_cache:
            return jsonify({
                "success": True,
                "analysis": game_analysis_cache[game_id],
                "cached": True
            })
        
        prompt = f"""Analyze this Roblox game for potential exploits:

Game: {game_name}
Game ID: {game_id}

Provide:
1. Common exploit types that work (ESP, Aimbot, Speed, etc)
2. Likely remote events to look for
3. Anti-cheat detection methods
4. Best practices for exploiting this type of game
5. Script suggestions

Be specific and technical."""

        analysis = call_groq(prompt, "You are a Roblox game security analyst and exploit developer.")
        
        # Cache it
        game_analysis_cache[game_id] = analysis
        
        return jsonify({
            "success": True,
            "analysis": analysis,
            "game_id": game_id,
            "game_name": game_name,
            "cached": False
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/deobfuscate', methods=['POST'])
def deobfuscate():
    """Deobfuscate Lua scripts"""
    try:
        data = request.get_json()
        code = data.get('code', '')
        
        if not code:
            return jsonify({"error": "Missing code"}), 400
        
        prompt = f"""Deobfuscate this Lua script and explain what it does:

```lua
{code}
```

Provide:
1. The deobfuscated clean code
2. Explanation of what the script does
3. Any security concerns or malicious behavior"""

        result = call_groq(prompt, "You are an expert at deobfuscating and analyzing Lua code.")
        
        return jsonify({
            "success": True,
            "result": result
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/ai-chat', methods=['POST'])
def ai_chat():
    """Chat with AI assistant"""
    try:
        data = request.get_json()
        message = data.get('message', '')
        
        if not message:
            return jsonify({"error": "Missing message"}), 400
        
        system_prompt = """You are a helpful Roblox exploit development assistant. 
Help users with:
- Script development
- Exploit techniques
- Game analysis
- Debugging
- Best practices

Be concise, helpful, and technical."""

        response = call_groq(message, system_prompt)
        
        return jsonify({
            "success": True,
            "response": response,
            "timestamp": datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/find-remotes', methods=['POST'])
def find_remotes():
    """AI suggests likely remote events for a game"""
    try:
        data = request.get_json()
        game_type = data.get('game_type', '')
        features = data.get('features', [])
        
        prompt = f"""For a Roblox {game_type} game with these features: {', '.join(features)}

List the most likely RemoteEvent and RemoteFunction names used for:
- Money/Currency
- Items/Inventory
- Combat/Damage
- Admin commands
- Teleportation
- Player stats

Provide realistic remote names that developers commonly use."""

        result = call_groq(prompt, "You are a Roblox game developer and reverse engineer.")
        
        return jsonify({
            "success": True,
            "remotes": result
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/improve-script', methods=['POST'])
def improve_script():
    """AI improves/fixes a script"""
    try:
        data = request.get_json()
        code = data.get('code', '')
        issue = data.get('issue', 'general improvement')
        
        if not code:
            return jsonify({"error": "Missing code"}), 400
        
        prompt = f"""Improve this Roblox script. Issue: {issue}

Current code:
```lua
{code}
```

Provide:
1. Improved version of the code
2. Explanation of changes made
3. Why these improvements help"""

        result = call_groq(prompt, "You are an expert Roblox script optimizer.")
        
        return jsonify({
            "success": True,
            "improved": result
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/stats', methods=['GET'])
def stats():
    """Get API statistics"""
    return jsonify({
        "cached_scripts": len(script_cache),
        "cached_games": len(game_analysis_cache),
        "api_status": "operational",
        "model": "Llama 3.1 70B via Groq"
    })

@app.route('/clear-cache', methods=['POST'])
def clear_cache():
    """Clear all caches"""
    global script_cache, game_analysis_cache
    script_cache = {}
    game_analysis_cache = {}
    
    return jsonify({
        "success": True,
        "message": "All caches cleared"
    })

if __name__ == '__main__':
    print("ðŸš€ Starting Prime X AI Hub...")
    print("ðŸ¤– Powered by Groq (Llama 3.1 70B)")
    print("="*60)
    
    if GROQ_API_KEY:
        print(f"âœ… Groq API Key: {GROQ_API_KEY[:20]}...")
    else:
        print("âŒ Groq API Key: NOT SET - Please add to environment variables!")
    
    print("="*60)
    print("ðŸ“‹ Available Features:")
    print("  - Script Generation")
    print("  - Game Analysis")
    print("  - Code Deobfuscation")
    print("  - AI Chat Assistant")
    print("  - Remote Finder")
    print("  - Script Improvement")
    print("="*60)
    
    port = int(os.environ.get('PORT', 10000))
    print(f"ðŸŒ Starting server on port {port}...")
    app.run(host='0.0.0.0', port=port)
