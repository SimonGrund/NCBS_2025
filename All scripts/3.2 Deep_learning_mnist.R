########
# 
# Assignment: Building a Neural Network - MNIST Classifier with R Keras
#
# Mathilde Diekema, Farhad Zamani
# Aarhus University
# 
#######

## Part 1: Setup
### Exercise 1: Install Required Library
# Install the necessary library: keras.
# Uncomment the following line to install the package if not already installed.
# install.packages("keras3")

# Load the libraries
library(keras3)

## Part 2: Load and Prepare the Data
### Exercise 2: Load the MNIST Dataset
# Load the MNIST dataset which is built into the Keras library.
mnist <- dataset_mnist()

# Split the dataset into training and testing sets.
X_train <- mnist$train$x # contains digits for the training set
y_train <- mnist$train$y # contains digits for the testing set
X_test <- mnist$test$x # contains labels for the training set
y_test <- mnist$test$y # contains labels for the testing set

### Exercise 3: Preprocess the Data

# We need to prepare our data before feeding it into the neural network. This
# involves reshaping and normalizing the input images, and converting the labels
# into a format suitable for the model. First, we will reshape the input images
# from 28x28 pixels to 1x784 each. You can do so with the array_reshape()
# function from Keras. Further, you'll also divide each value of the image
# matrix by 255, so all images are in the [0, 1] range.
#
# That will handle the input images, but we also have to convert the labels.
# These are stored as integers by default, and we'll convert them to categories
# with the to_categorical() function.

# Reshape the training data to have a single dimension of size 784 (28*28)
X_train <- array_reshape(X_train, c(nrow(X_train), 784))
# Normalize the training data by scaling pixel values to the range [0, 1]
X_train <- X_train / 255

# Reshape the test data to have a single dimension of size 784 (28*28)
X_test <- array_reshape(X_test, c(nrow(X_test), 784))
# Normalize the test data by scaling pixel values to the range [0, 1]
X_test <- X_test / 255

# Convert the training labels to one-hot encoded vectors with 10 categories
y_train <- to_categorical(y_train, num_classes = 10)
# Convert the test labels to one-hot encoded vectors with 10 categories
y_test <- to_categorical(y_test, num_classes = 10)


## Part 3: Build the Neural Network
### Exercise 4: Define the Model

# The MNIST dataset is both extensive and straightforward, making it ideal for
# achieving high accuracy with a relatively simple model architecture. In our
# neural network, we will include three hidden layers with 256, 128, and 64
# neurons, respectively. The output layer will have ten neurons, corresponding
# to the ten unique classes in the MNIST dataset.
# Once you declare the model, you can use the summary() function to print its 
# architecture:

# Create a sequential model.
model <- keras_model_sequential() %>%
  # Add layers to the model.
  layer_dense(units = 256, activation = "relu", input_shape = c(784)) %>%
  layer_dense(units = 128, activation = "relu") %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 10, activation = "softmax")
summary(model)

### Exercise 5: Compile the Model
# Before we start training our model, we need to complete one more step:
# compiling the model. This involves selecting a method to measure the loss,
# choosing an algorithm to minimize the loss, and deciding on a metric to
# evaluate the model's overall performance.
#
# We will use categorical cross-entropy for the loss function, the Adam
# optimizer to reduce the loss, and accuracy as the performance metric

model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_adam(),
  metrics = c('accuracy')
)

## Part 4: Train the Model 
## Exercise 6: Fit the Model 
# You can now proceed to train the model by using the fit() function. The
# following code snippet trains the model for 50 epochs, with a batch size of
# 128 images per training iteration:

history <- model %>% fit(
  X_train, y_train,
  epochs = 50,
  batch_size = 128,
  validation_split = 0.15
)

## Part 5: Evaluate the Model 
## Exercise 7: Evaluate the Model on Test Data and visualize some predictions
# You can assess the model's performance on the test set using the evaluate()
# function provided by Keras. Below is the code snippet to accomplish this:
model %>%
  evaluate(X_test, y_test)

# Select a random subset of test images and predict their classes. Compare the
# predicted classes with the true classes.
set.seed(123)
indices <- sample(1:nrow(X_test), 20)
x_subset <- X_test[indices,]
y_subset <- y_test[indices,]

# Make predictions
predictions <- model %>%
  predict(x_subset) %>%
  op_argmax(axis=-1)

predictions$numpy()

# Plot the results with corrected orientation
par(mfrow=c(2, 5))
for (i in 1:10) {
  img <- array_reshape(x_subset[i,], c(28, 28))
  img <- t(img)[, nrow(img):1] # Transpose and flip the image to correct orientation
  true_label <- which.max(y_subset[i,]) - 1
  pred_label <- predictions[i] - 1
  image(1:28, 1:28, img, col=gray.colors(255), main=paste("True:", true_label, "Pred:", pred_label))
}


## Part 6: Exercises and Questions
# 1. Modify the neural network to include additional layers. Observe how the performance changes.
# 2. Experiment with different optimizers (e.g., SGD, RMSprop) and compare the results.
# 3. Change the number of epochs and batch size. How do these parameters affect the training time and accuracy?
# 4. Visualize the training and validation accuracy/loss over epochs using a plot.
