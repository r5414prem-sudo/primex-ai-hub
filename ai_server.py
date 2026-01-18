from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import requests
import json
import re
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Groq API Configuration
GROQ_API_KEY = os.environ.get('GROQ_API_KEY')
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

if not GROQ_API_KEY:
    print("⚠️  WARNING: GROQ_API_KEY not set in environment variables!")
    print("   Please add it in Render dashboard under Environment tab")

# Enhanced caching
script_cache = {}
game_analysis_cache = {}
deobfuscation_cache = {}
remote_cache = {}

def call_groq(prompt, system_prompt="You are a helpful Roblox scripting assistant.", temperature=0.7, max_tokens=2000):
    """Enhanced Groq API call with better error handling"""
    try:
        response = requests.post(
            GROQ_API_URL,
            headers={
                "Authorization": f"Bearer {GROQ_API_KEY}",
                "Content-Type": "application/json"
            },
            json={
                "model": "llama-3.1-70b-versatile",
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": prompt}
                ],
                "temperature": temperature,
                "max_tokens": max_tokens
            },
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            return data['choices'][0]['message']['content']
        else:
            return f"Error: {response.status_code} - {response.text}"
            
    except requests.exceptions.Timeout:
        return "Error: Request timed out. Please try again."
    except Exception as e:
        return f"Error calling Groq API: {str(e)}"

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        "status": "online",
        "service": "Prime X AI Hub v2.0 - Enhanced Edition",
        "version": "2.0",
        "features": [
            "script_generation",
            "game_analysis",
            "advanced_deobfuscation",
            "ai_chat",
            "remote_finder",
            "script_improvement",
            "tool_detection_support"
        ],
        "ai_model": "Llama 3.1 70B",
        "enhancements": [
            "Better deobfuscation",
            "Remote event prediction",
            "Game vulnerability analysis",
            "Enhanced caching"
        ]
    })

@app.route('/generate-script', methods=['POST'])
def generate_script():
    """Generate Roblox exploit script with enhanced prompting"""
    try:
        data = request.get_json()
        description = data.get('description', '')
        game_name = data.get('game', 'Universal')
        place_id = data.get('placeId', 'Unknown')
        
        if not description:
            return jsonify({"error": "Missing description"}), 400
        
        # Enhanced cache key
        cache_key = f"{game_name}_{place_id}_{description}".lower()
        if cache_key in script_cache:
            return jsonify({
                "success": True,
                "script": script_cache[cache_key],
                "cached": True,
                "message": "Script retrieved from cache (instant!)"
            })
        
        # Enhanced prompt for better script generation
        prompt = f"""Generate a professional, working Roblox Lua exploit script for: {description}

Game: {game_name}
Place ID: {place_id}

REQUIREMENTS:
1. Must be complete, working code (not pseudocode)
2. Include comprehensive error handling
3. Add clear comments explaining functionality
4. Optimize for performance
5. Include safety checks where appropriate
6. Make it production-ready

IMPORTANT: Output ONLY the Lua code with comments. No markdown formatting, no explanations outside comments.

Generate the complete script:"""

        system_prompt = """You are an elite Roblox exploit script developer with deep knowledge of:
- Roblox Lua API and services
- Exploit development best practices
- Game security and anti-cheat evasion
- Performance optimization
- Error handling and edge cases

Generate clean, efficient, well-documented Lua code that works reliably.
Always include proper game instance checks, error handling, and optimization.
Output ONLY Lua code with inline comments - no markdown, no extra explanations."""

        script = call_groq(prompt, system_prompt, temperature=0.7, max_tokens=2500)
        
        # Clean up potential markdown formatting
        script = re.sub(r'```lua\n?', '', script)
        script = re.sub(r'```\n?', '', script)
        script = script.strip()
        
        # Cache the result
        script_cache[cache_key] = script
        
        return jsonify({
            "success": True,
            "script": script,
            "cached": False,
            "game": game_name,
            "description": description,
            "place_id": place_id
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/analyze-game', methods=['POST'])
def analyze_game():
    """Enhanced game analysis with vulnerability detection"""
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
        
        prompt = f"""Perform a comprehensive security analysis of this Roblox game for exploit development:

Game: {game_name}
Game ID: {game_id}

Provide detailed analysis covering:

1. EXPLOIT TYPES (What works best):
   - ESP/Wallhacks feasibility
   - Aimbot potential
   - Speed/teleportation exploits
   - Item/currency manipulation
   - God mode possibilities

2. REMOTE EVENTS TO TARGET:
   - Likely RemoteEvent names
   - RemoteFunction targets
   - Vulnerable endpoints
   - Common patterns for this game type

3. ANTI-CHEAT DETECTION:
   - Detection methods likely used
   - How to bypass them
   - Safe exploitation techniques

4. RECOMMENDED APPROACH:
   - Step-by-step exploitation strategy
   - Tools to use (Dex, Remote Spy, etc.)
   - Risk assessment

5. SCRIPT SUGGESTIONS:
   - Specific features to implement
   - Code snippets or techniques

Be technical, specific, and actionable."""

        system_prompt = """You are an expert Roblox game security analyst and exploit developer.
Provide detailed, technical analysis focused on practical exploitation.
Be specific about vulnerability vectors and exploitation techniques.
Give actionable advice that exploit developers can immediately use."""

        analysis = call_groq(prompt, system_prompt, temperature=0.6, max_tokens=3000)
        
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
    """Enhanced deobfuscation with pattern recognition"""
    try:
        data = request.get_json()
        code = data.get('code', '')
        
        if not code:
            return jsonify({"error": "Missing code"}), 400
        
        # Check cache
        code_hash = str(hash(code))
        if code_hash in deobfuscation_cache:
            return jsonify({
                "success": True,
                "result": deobfuscation_cache[code_hash],
                "cached": True
            })
        
        prompt = f"""Deobfuscate and analyze this Lua script comprehensively:

```lua
{code[:4000]}  # Limit code length for API
```

Provide:

1. DEOBFUSCATED CODE:
   - Clean, readable version
   - Proper variable names
   - Comments explaining logic
   - Formatted for readability

2. FUNCTIONALITY ANALYSIS:
   - What the script does
   - Key features and behaviors
   - Any hidden functionality

3. SECURITY CONCERNS:
   - Malicious behavior (if any)
   - Backdoors or data exfiltration
   - Remote connections
   - Dangerous operations

4. OBFUSCATION TECHNIQUES USED:
   - Methods employed
   - Complexity level
   - How to reverse similar code

Be thorough and provide the complete deobfuscated code."""

        system_prompt = """You are an expert at reverse engineering and deobfuscating Lua code.
You understand all common obfuscation techniques including:
- Variable name mangling
- String encryption
- Control flow obfuscation
- Constant folding
- Dead code injection

Provide clear, well-formatted deobfuscated code with detailed analysis."""

        result = call_groq(prompt, system_prompt, temperature=0.3, max_tokens=3500)
        
        # Cache the result
        deobfuscation_cache[code_hash] = result
        
        return jsonify({
            "success": True,
            "result": result,
            "cached": False
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/ai-chat', methods=['POST'])
def ai_chat():
    """Enhanced AI chat with context awareness"""
    try:
        data = request.get_json()
        message = data.get('message', '')
        
        if not message:
            return jsonify({"error": "Missing message"}), 400
        
        system_prompt = """You are an expert Roblox exploit development assistant with deep knowledge of:
- Lua scripting and Roblox API
- Exploit techniques and methodologies
- Game analysis and reverse engineering
- Anti-cheat bypassing
- Script optimization
- Debugging and troubleshooting

Help users with:
- Script development and debugging
- Exploit techniques and strategies
- Game analysis and vulnerability discovery
- Best practices and optimization
- Tool recommendations

Be helpful, technical, concise, and provide actionable advice.
Include code examples when relevant.
Be encouraging and supportive."""

        response = call_groq(message, system_prompt, temperature=0.7, max_tokens=2000)
        
        return jsonify({
            "success": True,
            "response": response,
            "timestamp": datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/find-remotes', methods=['POST'])
def find_remotes():
    """AI predicts likely remote events with enhanced accuracy"""
    try:
        data = request.get_json()
        game_type = data.get('game_type', '')
        features = data.get('features', [])
        
        cache_key = f"{game_type}_{'_'.join(features)}"
        if cache_key in remote_cache:
            return jsonify({
                "success": True,
                "remotes": remote_cache[cache_key],
                "cached": True
            })
        
        prompt = f"""Analyze and predict RemoteEvent/RemoteFunction names for a Roblox {game_type} game with these features: {', '.join(features)}

Provide realistic, commonly-used remote names that developers typically use for:

1. CURRENCY/ECONOMY:
   - Money/cash remotes
   - Shop/purchase remotes
   - Reward/claim remotes

2. ITEMS/INVENTORY:
   - Item management
   - Equipment/tools
   - Trading systems

3. COMBAT/DAMAGE:
   - Damage dealing
   - Hit detection
   - Combat actions

4. ADMIN/MODERATION:
   - Admin commands
   - Kick/ban systems
   - Server controls

5. PLAYER SYSTEMS:
   - Teleportation
   - Stats/levels
   - Data saving

6. GAME MECHANICS:
   - Specific to this game type
   - Core gameplay remotes

For each category:
- List 3-5 most likely names
- Explain typical parameters
- Note exploitation potential
- Suggest testing methods

Be specific and realistic based on common Roblox development patterns."""

        system_prompt = """You are a Roblox game developer and reverse engineer with extensive knowledge of:
- Common naming conventions developers use
- Standard game architecture patterns
- Remote event/function implementation
- Game-specific mechanics

Provide realistic remote names that are actually used in Roblox games.
Base predictions on proven patterns and real-world examples."""

        result = call_groq(prompt, system_prompt, temperature=0.5, max_tokens=2500)
        
        # Cache it
        remote_cache[cache_key] = result
        
        return jsonify({
            "success": True,
            "remotes": result,
            "cached": False
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/improve-script', methods=['POST'])
def improve_script():
    """AI improves/fixes scripts with detailed explanations"""
    try:
        data = request.get_json()
        code = data.get('code', '')
        issue = data.get('issue', 'general improvement')
        
        if not code:
            return jsonify({"error": "Missing code"}), 400
        
        prompt = f"""Improve this Roblox exploit script. Issue/Request: {issue}

Current code:
```lua
{code[:3000]}
```

Provide:

1. IMPROVED CODE:
   - Complete, working version
   - All improvements implemented
   - Well-commented

2. CHANGES MADE:
   - Detailed list of modifications
   - Why each change was necessary
   - Performance/stability benefits

3. ADDITIONAL RECOMMENDATIONS:
   - Further improvements possible
   - Best practices to follow
   - Potential issues to watch for

Output the complete improved code first, then explanations."""

        system_prompt = """You are an expert Roblox script optimizer and debugger.
Improve code for:
- Performance and efficiency
- Reliability and error handling
- Code quality and readability
- Security and safety
- Best practices compliance

Provide production-ready, well-documented improvements."""

        result = call_groq(prompt, system_prompt, temperature=0.5, max_tokens=3000)
        
        return jsonify({
            "success": True,
            "improved": result
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/stats', methods=['GET'])
def stats():
    """Get detailed API statistics"""
    return jsonify({
        "cached_scripts": len(script_cache),
        "cached_games": len(game_analysis_cache),
        "cached_deobfuscations": len(deobfuscation_cache),
        "cached_remotes": len(remote_cache),
        "total_cache_entries": len(script_cache) + len(game_analysis_cache) + len(deobfuscation_cache) + len(remote_cache),
        "api_status": "operational",
        "model": "Llama 3.1 70B via Groq",
        "version": "2.0"
    })

@app.route('/clear-cache', methods=['POST'])
def clear_cache():
    """Clear all caches with confirmation"""
    global script_cache, game_analysis_cache, deobfuscation_cache, remote_cache
    
    old_counts = {
        "scripts": len(script_cache),
        "games": len(game_analysis_cache),
        "deobfuscations": len(deobfuscation_cache),
        "remotes": len(remote_cache)
    }
    
    script_cache = {}
    game_analysis_cache = {}
    deobfuscation_cache = {}
    remote_cache = {}
    
    return jsonify({
        "success": True,
        "message": "All caches cleared successfully",
        "cleared": old_counts,
        "timestamp": datetime.now().isoformat()
    })

if __name__ == '__main__':
    print("="*70)
    print("🚀 Starting Prime X AI Hub v2.0 - Enhanced Edition")
    print("🤖 Powered by Groq (Llama 3.1 70B)")
    print("="*70)
    
    if GROQ_API_KEY:
        print(f"✅ Groq API Key: {GROQ_API_KEY[:20]}...")
    else:
        print("❌ Groq API Key: NOT SET - Please add to environment variables!")
    
    print("="*70)
    print("📋 Available Features:")
    print("  ✓ Advanced Script Generation")
    print("  ✓ Comprehensive Game Analysis")
    print("  ✓ Enhanced Code Deobfuscation")
    print("  ✓ AI Chat Assistant")
    print("  ✓ Remote Event Prediction")
    print("  ✓ Script Improvement & Optimization")
    print("  ✓ Multi-level Caching System")
    print("="*70)
    print("🎯 Enhancements in v2.0:")
    print("  • Better prompting for higher quality output")
    print("  • Enhanced deobfuscation capabilities")
    print("  • Improved remote event prediction")
    print("  • Detailed game vulnerability analysis")
    print("  • Markdown cleanup for cleaner code")
    print("  • Extended token limits for complex tasks")
    print("="*70)
    
    port = int(os.environ.get('PORT', 10000))
    print(f"🌐 Starting server on port {port}...")
    print("="*70)
    app.run(host='0.0.0.0', port=port)
