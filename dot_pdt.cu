#include <stdio.h>
#include <cuda_runtime.h>
#include <time.h>


#define imin(a,b) (a<b?a:b)
#define HANDLE_ERROR(err) (HandleError(err, __FILE__, __LINE__))

static void HandleError(cudaError_t err, const char *file, int line) {
    if (err != cudaSuccess) {
        printf("%s in %s at line %d\n", cudaGetErrorString(err), file, line);
        exit(EXIT_FAILURE);
    }
}
const int N = 33*1024;

const int threadsPerBlock = 256;

__global__ void dot(float *a,float *b, float *c){
    __shared__ float cache[threadsPerBlock];

    int tid = threadIdx.x + blockIdx.x*blockDim.x;
    int cacheIdx = threadIdx.x;
    float temp = 0;

    while (tid<N){
        temp += a[tid]*b[tid];
        tid+=blockDim.x*gridDim.x;
         
    }
    cache[cacheIdx] = temp;

    __syncthreads();

    int i = blockDim.x/2;


    while(i!=0){
        if(cacheIdx<i)
            cache[cacheIdx] +=cache[cacheIdx+i];
        
        __syncthreads(); //MUST be outside of if statement

        i/=2;
    }
    if(cacheIdx==0)  //this could have been any thread not just the one with cacheIdx = 0
        c[blockIdx.x] = cache[0];
    }


    
const int blocksPerGrid = imin(32,(N+threadsPerBlock-1)/threadsPerBlock);

int main(void){
    float *a,*b,c,*partial_c;
    float *dev_a,*dev_b,*dev_partial_c;

    a = (float*)malloc(N*sizeof(float));
    b = (float*)malloc(N*sizeof(float));
    partial_c = (float*)malloc(blocksPerGrid*sizeof(float));

    //allocate Memory
    HANDLE_ERROR(cudaMalloc(&dev_a,N*sizeof(float)));
    HANDLE_ERROR(cudaMalloc(&dev_b,N*sizeof(float)));
    HANDLE_ERROR(cudaMalloc(&dev_partial_c,blocksPerGrid*sizeof(float)));

    for (int i=0; i<N; i++){
        a[i]=i;
        b[i]=i*2;
    }


    HANDLE_ERROR(cudaMemcpy(dev_a,a,N*sizeof(float),cudaMemcpyHostToDevice));
    HANDLE_ERROR(cudaMemcpy(dev_b,b,N*sizeof(float),cudaMemcpyHostToDevice));

    dot <<<blocksPerGrid,threadsPerBlock>>>(dev_a,dev_b,dev_partial_c);
    
    HANDLE_ERROR(cudaMemcpy(partial_c,dev_partial_c,blocksPerGrid*sizeof(float),cudaMemcpyDeviceToHost));

    c = 0;
    for (int i=0; i <blocksPerGrid; i++){ 
        c+=partial_c[i];
    }

    printf("%f",c);

    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_partial_c);
    
    free(a);
    free(b);
    free(partial_c);

    
}