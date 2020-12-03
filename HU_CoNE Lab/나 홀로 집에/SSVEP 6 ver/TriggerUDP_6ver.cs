using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerUDP_6ver : MonoBehaviour {

    public GameObject UDPCommGameObject;

    public string StartTrigger;
    public string EndTrigger;



    void Start()
    {
        if (UDPCommGameObject == null)
        {
            Debug.Log("ERR UDPGEN: UDPSender is required. Self-destructing.");
            Destroy(this);
        }


    }


    void Update()
    {
        if ((Stimuli_main.checker_1 == 0 && Stimuli_main.checker_2 == 1))
        {
            Debug.Log("Starting Point: " + Stimuli_main.StartTrigger);

            if (Stimuli_main.StartTrigger != null)
            {
                // UTF-8 is real
                var dataBytes = System.Text.Encoding.UTF8.GetBytes(Stimuli_main.StartTrigger);
                UDPCommunication comm = UDPCommGameObject.GetComponent<UDPCommunication>();

                // #if is required because SendUDPMessage() is async
#if !UNITY_EDITOR
			comm.SendUDPMessage(comm.externalIP, comm.externalPort, dataBytes); 
#endif
            }
        }


        if ((Stimuli_main.checker_1 == 1 && Stimuli_main.checker_2 == 0) )
        {
            Debug.Log("Ending Point: " + Stimuli_main.EndTrigger);

            if (Stimuli_main.EndTrigger != null)
            {
                // UTF-8 is real
                var dataBytes = System.Text.Encoding.UTF8.GetBytes(Stimuli_main.EndTrigger);
                UDPCommunication comm = UDPCommGameObject.GetComponent<UDPCommunication>();

                // #if is required because SendUDPMessage() is async
#if !UNITY_EDITOR
			comm.SendUDPMessage(comm.externalIP, comm.externalPort, dataBytes);
#endif
            }
        }


    }


        /* ORIGINAL
         * 
         * if (DataString != null) {
			// UTF-8 is real
			var dataBytes = System.Text.Encoding.UTF8.GetBytes(DataString);
			UDPCommunication comm = UDPCommGameObject.GetComponent<UDPCommunication> ();

			// #if is required because SendUDPMessage() is async
			#if !UNITY_EDITOR
			comm.SendUDPMessage(comm.externalIP, comm.externalPort, dataBytes);
			#endif
		}*/

    
}
