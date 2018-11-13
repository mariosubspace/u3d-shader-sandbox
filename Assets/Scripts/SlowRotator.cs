using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlowRotator : MonoBehaviour
{
    public float rotateSpeed = 90f;

    void Update()
    {
        transform.Rotate(Vector3.up, rotateSpeed * Time.deltaTime, Space.World);
    }
}
