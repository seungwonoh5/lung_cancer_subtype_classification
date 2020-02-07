# Required Python Packages
import sklearn
print (sklearn.__version__)
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from sklearn.metrics import confusion_matrix

def main():

    # Load the csv file into pandas dataframe
    filename = '~/data/rfc_dataset.csv'
    dataset = pd.read_csv(filename) # <class 'pandas.core.frame.DataFrame'>

    # Check dataset size details and if the data is loaded correctly
    print(dataset.shape)
    print(dataset.head()) 
    
    # Extract column names from csv files
    HEADERS = dataset.columns.values # type : Numpy (HEADERS = dataset.columns <class 'pandas.core.indexes.base.Index'>)

    # Randomly split dataset into train and test
    train_x, test_x, train_y, test_y = train_test_split(dataset[HEADERS[0:-1]], dataset[HEADERS[-1]], train_size=0.7)

    # Check if Train and Test dataset are correctly split
    print("Train_x Shape :: ", train_x.shape)
    print("Train_y Shape :: ", train_y.shape)
    print("Test_x Shape :: ", test_x.shape)
    print ("Test_y Shape :: ", test_y.shape)
    
    for _ in range(10):
        # Create random forest classifier instance and train
        model = RandomForestClassifier()
        model.fit(train_x, train_y)
		train_acc = accuracy_score(train_y, model.predict(train_x))

        # Evaluate trained classifier on test set
        predictions = model.predict(test_x)
        test_acc = accuracy_score(test_y, predictions)
        
        # print out train, test results and draw a confusion matrix
        print("Train 1st_Accuracy :: ", train_acc)
        print("Test 1st_Accuracy  :: ", test_acc)
        print("Confusion matrix ", confusion_matrix(test_y, predictions))
    
if __name__ == "__main__":
    main()