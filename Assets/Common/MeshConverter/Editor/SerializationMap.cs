
// Serialization.cs
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

[Serializable]
public class SerializationList<T>
{
    [SerializeField]
    List<T> target;
    public List<T> ToList() { return target; }

    public SerializationList(List<T> target)
    {
        this.target = target;
    }
}
// Dictionary<TKey, TValue>
[Serializable]
public class SerializationMap<TKey, TValue> : ISerializationCallbackReceiver
{
    [SerializeField]
    List<TKey> keys;
    [SerializeField]
    List<TValue> values;

    public Dictionary<TKey, TValue> target;
    public Dictionary<TKey, TValue> ToDictionary() { return target; }

    public SerializationMap(Dictionary<TKey, TValue> target)
    {
        this.target = target;
    }

    public void OnBeforeSerialize()
    {
        keys = new List<TKey>(target.Keys);
        values = new List<TValue>(target.Values);
    }

    public void OnAfterDeserialize()
    {
        var count = Math.Min(keys.Count, values.Count);
        target = new Dictionary<TKey, TValue>(count);
        for (var i = 0; i < count; ++i)
        {
            target.Add(keys[i], values[i]);
        }
    }
}


// Dictionary<TKey, TValue>
[Serializable]
public class SerializationMap1 : ISerializationCallbackReceiver
{
    [SerializeField]
    List<ESemantic> keys;
    [SerializeField]
    List<ConvertStrategy.BufferDataInfo> values;

    public Dictionary<ESemantic, ConvertStrategy.BufferDataInfo> target;
    public Dictionary<ESemantic, ConvertStrategy.BufferDataInfo> ToDictionary() { return target; }

    public SerializationMap1(Dictionary<ESemantic, ConvertStrategy.BufferDataInfo> target)
    {
        this.target = target;
    }

    public void OnBeforeSerialize()
    {
        keys = new List<ESemantic>(target.Keys);
        values = new List<ConvertStrategy.BufferDataInfo>(target.Values);
    }

    public void OnAfterDeserialize()
    {
        var count = Math.Min(keys.Count, values.Count);
        target = new Dictionary<ESemantic, ConvertStrategy.BufferDataInfo>(count);
        for (var i = 0; i < count; ++i)
        {
            target.Add(keys[i], values[i]);
        }
    }
}