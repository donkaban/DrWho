using UnityEngine;
using System.Collections;

public class ArcBallController : MonoBehaviour 
{
    public float damping = 0.999f;
    public float speed = 5f;

    private Vector3 down;
    private Vector3 drag;
    private bool    dragging = false;
    private float   velocity;
    private Vector3 axis;

    void Start()
    {
        velocity = 0;
        axis = Vector3.zero;
    }

    void Update()
    {   
        if(Input.GetMouseButton(0)) 
        {
            var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;

            if(Physics.Raycast(ray, out hit)) 
            {
                if(!dragging )
                {
                    down = hit.point - transform.position;
                    dragging = true;
                }
                else
                {
                    drag = hit.point - transform.position;
                    axis = Vector3.Cross(down, drag);
                    velocity = Vector3.Angle(down, drag) * speed;
                }
            }
            else
                dragging = false;
        }

        if(Input.GetMouseButtonUp(0))
            dragging = false;

        if( velocity > 0 )
        {
            transform.RotateAround(transform.position, axis, velocity * Time.deltaTime );
            velocity = (velocity > 0.01f) ? velocity * damping : 0;
        }
    }
}
