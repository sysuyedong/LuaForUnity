using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using LuaInterface;
using UnityEngine;

namespace LuaForUnity
{
    public delegate void LuaFuncHandler();
    public delegate void LoadFileFinishHandler(byte[] buffer);
    public class LuaMainEngine
    {
        private LuaFunction m_func_start;
        private LuaFuncHandler m_hanler_start;
        public LuaFuncHandler Start
        {
            get 
            {
                return m_hanler_start; 
            }
        }

        private LuaFunction m_func_update;
        private LuaFuncHandler m_hanler_update;
        public LuaFuncHandler Update
        {
            get 
            {
                return m_hanler_update;
            }
        }

        private LuaFunction m_func_destroy;
        private LuaFuncHandler m_hanler_destroy;
        public LuaFuncHandler OnDestroy
        {
            get 
            {
                return m_hanler_destroy;
            }
        }

        public bool EngineInit = false;
        private LuaState m_lua_state;

        public bool InitLuaFile(MonoBehaviour mono, string lua_path)
        {
            //ToDo:Load lua file throgth dynamic loading(WWW)
            m_lua_state = new LuaState();
            LoadFileFinishHandler handler = (buffer) =>
            {
                string str = System.Text.Encoding.UTF8.GetString(buffer);
                m_lua_state.DoString(str);
                m_func_start = m_lua_state["Start"] as LuaFunction;
                m_func_update = m_lua_state["Update"] as LuaFunction;
                m_func_destroy = m_lua_state["OnDestroy"] as LuaFunction;

                m_hanler_start = () =>
                {
                    m_func_start.Call();
                };
                m_hanler_update = () =>
                {
                    m_func_update.Call();
                };
                m_hanler_destroy = () =>
                {
                    m_func_destroy.Call();
                };
                EngineInit = true;
                m_hanler_start();
            };
            mono.StartCoroutine(LoadFile(lua_path, handler));
            return true;
        }

        private IEnumerator LoadFile(string file_name, LoadFileFinishHandler handler)
        {
            WWW www = new WWW("file://" + Application.streamingAssetsPath + "/" + file_name);
            yield return www;

            if(www.error != null)
            {
                Debug.LogError("Load file error:" + www.error);
            }
            else
            {
                byte[] buffer = www.bytes;
                handler(buffer);
            }
            www.Dispose();
            www = null;
        }
    }
}
