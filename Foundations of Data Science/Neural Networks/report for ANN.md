### Implementation of ANN on MNIST dataset

In this task, we are required to construct an ANN model for MNIST dataset. This is a handwritte digit classificatio task. The input is the $28\times 28$-pixel handwritten digits and the output is the number from 0 to 9. Therefore, the input layer and output layer are determined. We only have to build hidden layers. This task is quite straightforward. I used trial-and-error approach to find the optimal layers and neurons for each layers. We know that the past common practice is to form a pyramid (the number of neurons for each hidden layer is decreasing from top to bottom layer) while the new trend is to use the same number of neurons in all hidden layers. I used the old-fashioned structure to build the model and it worked pretty well.

Why ReLU?

Comparing to *Sigmoid* activation function, *ReLU* can solve problems regarding vanishing gradients

Why Adam?

*Adam* optimizer combines the best properties of the *AdaGrad* and *RMSProp* algorithms to provide an optimization algorithm that can handle sparse gradients on noisy problems.