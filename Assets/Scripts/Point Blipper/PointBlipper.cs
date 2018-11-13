using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PointBlipper : MonoBehaviour
{
    Material mat;
    const int MAX_HITS = 8;

    Vector3 localHitPosition;
    float hitStrength = 0f;

    [Range(0, 1)]
    public float decayRate = 0.9f;

    void Awake()
    {
        mat = GetComponent<MeshRenderer>().material;
    }

    void Update()
    {
        mat.SetVector("hitPosition", transform.TransformPoint(localHitPosition));
        mat.SetFloat("hitStrength", hitStrength);

        hitStrength *= decayRate;
    }

    void OnCollisionEnter(Collision other)
    {
        localHitPosition = transform.InverseTransformPoint(other.contacts[0].point);
        hitStrength = 1f;
    }
}
