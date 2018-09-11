#%%
import os
import scipy.io
import numpy as np
#%%

from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation, Flatten
from keras.layers import Convolution2D, MaxPooling2D
from keras.utils import np_utils
from keras import backend as K
K.set_image_dim_ordering('th')

data = scipy.io.loadmat('traindata.mat')
train_img = np.asarray(data['trainX'])

#%%
# Size is number of patches, number of input feature maps, patch height, patch width
train_img = np.reshape(train_img,(train_img.shape[0],3,64,64))
print('Size of training data is '+str(train_img.shape))
train_out = np.asarray(data['trainY'])
print('Size of training target is '+str(train_out.shape))



#%%
#Loading testing data  
data = scipy.io.loadmat('testdata.mat')
test_img = np.asarray(data['testX'])


# Size is number of patches, number of input feature maps, patch height, patch width
test_img = np.reshape(test_img,(test_img.shape[0],3,64,64))
print('Size of testing data is '+ str(test_img.shape))

train_img = train_img.astype('float32')
test_img = test_img.astype('float32')


train_img = train_img / 255 ;
test_img = test_img / 255 ;

#%%
print(train_img.shape[0], 'train samples')
print(test_img.shape[0], 'test samples')

# convert class vectors to binary class matrices
train_out = train_out.astype('int')
train_out = np_utils.to_categorical(train_out, 2)



#%%
model = Sequential()

model.add(Convolution2D(32, 3, 3, border_mode='valid', input_shape=(3,64,64) ) )
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
#to reduce output dimensionality
model.add(Dropout(0.25))
#dropout is used to reduce overfitting
model.add(Convolution2D(70, 3, 3))
model.add(Activation('relu'))

model.add(MaxPooling2D(pool_size=(2, 2)))
#to reduce output dimensionality
model.add(Dropout(0.25))
#dropout is used to reduce overfitting
#%%
model.add(Flatten())
model.add(Dense(512))
model.add(Activation('relu'))
model.add(Dropout(0.5))
#to reduce overfitting dropout is used
model.add(Dense(2))
model.add(Activation('softmax'))
#to map to probability space

#%%
# let's train the model

model.compile(loss='categorical_crossentropy',
              optimizer='adadelta',
              metrics=['accuracy'])
print('compilation has completed') ;
#%%


model.fit(train_img,train_out, batch_size=126, nb_epoch=10,verbose=1,validation_split = 0.1 )

#%%
model.predict_classes(test_img , batch_size = 100) 
