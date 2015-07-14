using UnityEngine;
using System.Collections;
using LuaInterface;

namespace LuaForUnity
{

    public class Main : MonoBehaviour
    {
        private LuaMainEngine m_lua_engine;

        void Awake()
        {
            m_lua_engine = new LuaMainEngine();
            m_lua_engine.InitLuaFile(this, "lua/engine_main.lua");
        }

        // Use this for initialization
        void Start()
        {
        }

        // Update is called once per frame
        void Update()
        {
            if (m_lua_engine.EngineInit)
            {
                m_lua_engine.Update();
            }
        }

        void OnDestroy()
        {
            if (m_lua_engine.EngineInit)
            {
                m_lua_engine.OnDestroy();
            }
        }
    }
}
