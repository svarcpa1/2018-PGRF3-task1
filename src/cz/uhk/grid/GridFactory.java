package cz.uhk.grid;

import com.jogamp.opengl.GL2GL3;
import oglutils.OGLBuffers;

public class GridFactory {

    public static OGLBuffers create(GL2GL3 gl,int m, int n){
        //VB = m*n*2 => every vertex has two coordinates
        //*2 for texture
        float[] vertexBuffer = new float[2*2*m*n];
        int index=0;

        //filling VB with values
        //i/(m-1)
        if(m<=1 || n<=1) throw new RuntimeException("n or m <´1");

        for(int j = 0; j<n; j++){
            for(int i = 0; i<m; i++){
                vertexBuffer[index++]=((float)i/(m-1));
                vertexBuffer[index++]=((float)j/(n-1));

                //for textures
                vertexBuffer[index++]=((float)i/(m-1));
                vertexBuffer[index++]=((float)j/(n-1));
            }
        }

        //IB = (M-1)*(N-1)*2*3
        int[] indexBuffer = new int[(m-1)*(n-1)*2*3];
        int index2=0;

        for (int i =0; i<n-1; i++){
            for(int j=0; j<m-1; j++){
                indexBuffer[index2++] = (j+(i*m));
                indexBuffer[index2++] = (j+1+(i*m));
                indexBuffer[index2++] = (j+m+(i*m));

                indexBuffer[index2++] = (j+1+(i*m));
                indexBuffer[index2++] = (j+1+m+(i*m));
                indexBuffer[index2++] = (j+m+(i*m));
            }
        }

        // vertex binding description, concise version
        OGLBuffers.Attrib[] attributes = {
                new OGLBuffers.Attrib("inPosition", 2), // 2 floats
                new OGLBuffers.Attrib("inTexture", 2) //x,y to texture
        };
        return new OGLBuffers(gl, vertexBuffer, attributes, indexBuffer);
    }
}


