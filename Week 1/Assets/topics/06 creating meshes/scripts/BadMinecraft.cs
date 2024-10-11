using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof (MeshFilter))]
[RequireComponent(typeof (MeshRenderer))]
public class BadMinecraft : MonoBehaviour
{
    Mesh mesh;

    void Start()
    {
        MakeCube();
    }

    void MakeCube() {
        // define coordinates of each corner of the cube
        Vector3[] c =
        {
            new Vector3(0,0,0), // 0
            new Vector3(1,0,0), // 1
            new Vector3(1,1,0), // 2
            new Vector3(0,1,0), // 3
            new Vector3(0,1,1), // 4
            new Vector3(1,1,1), // 5
            new Vector3(1,0,1), // 6
            new Vector3(0,0,1) // 7
        };
        
        // define the vertices of the cube

        Vector3[] vertices =
        {
            //0     1     2     3
            c[0], c[1], c[2], c[3], // south face
            
            //4     5     6     7
            c[3], c[2], c[5], c[4], // top face
            
            //8     9     10    11
            c[1], c[6], c[5], c[2], // east face
            
            //12    13    14    15
            c[0], c[3], c[4], c[7], // west face
            
            //16    17    18    19
            c[7], c[4], c[5], c[6], // north face
            
            //20    21    22    23
            c[0], c[1], c[6], c[7] // bot face
        };
        
        Vector3 south = Vector3.back;
        Vector3 north = Vector3.forward;
        Vector3 east = Vector3.right;
        Vector3 west = Vector3.left;
        Vector3 up = Vector3.up;
        Vector3 down = Vector3.down;

        Vector3[] normals =
        {
            south, south, south, south, // south face
            up, up, up, up, // top face
            east, east, east, east, // east face
            west, west, west, west, // west face
            north, north, north, north, // north face
            down, down, down, down // bot face
        };

        Vector2[] uvs =
        {
            // 前面
            new(0.0f, 0.0f), new(0.5f, 0.0f), new(0.0f, 0.5f), new(0.5f, 0.5f),

            // 后面
            new(0.0f, 0.5f), new(0.5f, 0.5f), new(0.0f, 1.0f), new(0.5f, 1.0f),

            // 左面
            new(0.5f, 0.0f), new(1.0f, 0.0f), new(0.5f, 0.5f), new(1.0f, 0.5f),

            // 右面
            new(0.0f, 0.5f), new(0.5f, 0.5f), new(0.0f, 1.0f), new(0.5f, 1.0f),

            // 上面
            new(0.0f, 0.0f), new(0.5f, 0.0f), new(0.0f, 0.5f), new(0.5f, 0.5f),

            // 下面
            new(0.5f, 0.0f), new(1.0f, 0.0f), new(0.5f, 0.5f), new(1.0f, 0.5f)

        };

        int[] triangles =
        {
            // 前面
            0, 2, 1, 0, 3, 2,

            // 后面
            4, 6, 5, 4, 7, 6,

            // 左面
            8, 10, 9, 8, 11, 10,

            // 右面
            12, 14, 13, 12, 15, 14,

            // 上面
            16, 18, 17, 16, 19, 18,

            // 下面
            20, 22, 21, 20, 23, 22
        };

        mesh = GetComponent<MeshFilter>().mesh;
        mesh.Clear();
        
        mesh.vertices = vertices;
        
        mesh.normals = normals;
        
        mesh.uv = uvs;
        
        mesh.triangles = triangles;
    }

    private void OnDestroy()
    {
        Destroy(mesh);
    }
}
