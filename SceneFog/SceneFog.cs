using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;

[CustomEditor(typeof(SceneFog))]
public class SceneFogEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        var inst = target as SceneFog;

        if (GUILayout.Button("UpdateParams"))
        {
            inst.UpdateParams();
        }
    }
}

#endif
[ExecuteInEditMode]
public class SceneFog : MonoBehaviour
{
    // public readonly int SCENE_BOUNDS = Shader.PropertyToID("_SceneBounds");

    public Texture sceneFogMap;
    public Texture sceneMainNoiseMap, sceneDetailNoiseMap;
    public Vector4 mainFogNoiseTilingOffset = new Vector4(3, 3, 1, 0);

    public Vector4 detailFogTiling = new Vector4(5,5,5,5);
    public Vector4 detailFogOffset = new Vector4(-2, 0, 2, 0);

    [Header("Scene Bounds")]
    public bool sceneBoundsUseTransforms;
    public Transform sceneMinTr,sceneMaxTr;
    public Vector3 sceneMin = new Vector3(-200,-10,-200);
    public Vector3 sceneMax = new Vector3(200,10,200);
    [Header("Fog Area(min,max)")]
    public Vector2 fogAreaScale = new Vector2(0,1);
    [Header("Scene Fog")]
    public bool sceneFogOn = true;
    [Header("Height Fog")]
    public bool sceneHeightFogOn = false;
    [Range(1,2)]public float heightFogFading = 1;

    [Header("Camera Fading")]
    public float _CameraFadeDist = 10;

    public void UpdateParams()
    {
        Shader.SetGlobalTexture("_SceneFogMap", sceneFogMap);
        Shader.SetGlobalTexture("_FogMainNoiseMap", sceneMainNoiseMap);
        Shader.SetGlobalTexture("_FogDetailNoiseMap", sceneDetailNoiseMap);
        // Shader.SetGlobalVector("_SceneBounds", sceneBounds);
        if (sceneBoundsUseTransforms)
        {
            sceneMin = sceneMaxTr ? sceneMinTr.position : sceneMin;
            sceneMax = sceneMaxTr ? sceneMaxTr.position : sceneMax;
        }
        Shader.SetGlobalVector("_SceneMin", sceneMin);
        Shader.SetGlobalVector("_SceneMax", sceneMax);
        Shader.SetGlobalVector("_FogNoiseTilingOffset", mainFogNoiseTilingOffset);
        Shader.SetGlobalVector("_DetailFogOffset", detailFogOffset);
        Shader.SetGlobalVector("_DetailFogTiling", detailFogTiling);

        Shader.SetGlobalFloat("_SceneFogOn", sceneFogOn ? 1 : 0);
        Shader.SetGlobalFloat("_SceneHeightFogOn", sceneHeightFogOn ? 1 : 0);
        Shader.SetGlobalFloat("_SceneHeightFogFading", heightFogFading);

        Shader.SetGlobalFloat("_CameraFadeDist", _CameraFadeDist);
        Shader.SetGlobalVector("_FogAreaScale",fogAreaScale);
    }

    
    void Update(){
        UpdateParams();
    }
}
