#!/usr/bin/python

# Most of codes are done in jupyter notebook

import sys
import pickle
sys.path.append("../tools/")
import matplotlib.pyplot as plt

from feature_format import featureFormat, targetFeatureSplit
from tester import dump_classifier_and_data

### Task 1: Select what features you'll use.
### features_list is a list of strings, each of which is a feature name.
### The first feature must be "poi".
features_list = ['poi', 'salary', 'bonus', 'deferral_payments', 'total_payments', 'loan_advances', 'restricted_stock_deferred','deferred_income', 'total_stock_value', 'expenses', 'exercised_stock_options', 'long_term_incentive', 'restricted_stock', 'director_fees']
 # You will need to use more features

### Load the dictionary containing the dataset
with open("final_project_dataset.pkl", "r") as data_file:
    data_dict = pickle.load(data_file)

### Task 2: Remove outliers
data = featureFormat(data_dict, features_list)
data_dict.pop('TOTAL', 0)


### Task 3: Create new feature(s)
### Store to my_dataset for easy export below.
# Create my_dataset which is just a copy of data_dict, so I can keep both original and modified data
my_dataset = data_dict

for i in my_dataset:
    my_dataset[i]['from_to_poi'] = my_dataset[i]['from_this_person_to_poi'] + my_dataset[i]['from_poi_to_this_person']
    if my_dataset[i]['from_to_poi'] == 'NaNNaN':
        my_dataset[i]['from_to_poi'] = 'NaN'
        
for i in my_dataset:
    my_dataset[i]['communication_with_poi'] = my_dataset[i]['from_to_poi'] + my_dataset[i]['shared_receipt_with_poi']
    if my_dataset[i]['communication_with_poi'] == 'NaNNaN':
        my_dataset[i]['communication_with_poi'] = 'NaN'
        
#top 6 importances
features_list = ['poi', 'salary', 'bonus', 'communication_with_poi', 'deferral_payments', 'total_payments',
                 'loan_advances']

### Extract features and labels from dataset for local testing
data = featureFormat(my_dataset, features_list, sort_keys = True)
labels, features = targetFeatureSplit(data)

### Task 4: Try a varity of classifiers
### Please name your classifier clf for easy export below.
### Note that if you want to do PCA or other multi-stage operations,
### you'll need to use Pipelines. For more info:
### http://scikit-learn.org/stable/modules/pipeline.html

from sklearn import cross_validation
features_train, features_test, labels_train, labels_test = \
cross_validation.train_test_split(features, labels, test_size=0.1, random_state=42)
from sklearn.metrics import accuracy_score

# Provided to give you a starting point. Try a variety of classifiers.
from sklearn.ensemble import AdaBoostClassifier
clf = AdaBoostClassifier()
clf = clf.fit(features_train, labels_train)
pred = clf.predict(features_test)

### Task 5: Tune your classifier to achieve better than .3 precision and recall 
### using our testing script. Check the tester.py script in the final project
### folder for details on the evaluation method, especially the test_classifier
### function. Because of the small size of the dataset, the script uses
### stratified shuffle split cross validation. For more info: 
### http://scikit-learn.org/stable/modules/generated/sklearn.cross_validation.StratifiedShuffleSplit.html
clf_tuned = AdaBoostClassifier(n_estimators=79, learning_rate=1, algorithm='SAMME.R', random_state=42)
clf_tuned = clf_tuned.fit(features_train, labels_train)
pred_tuned = clf_tuned.predict(features_test)
acc_abc = accuracy_score(pred_tuned, labels_test)

### Task 6: Dump your classifier, dataset, and features_list so anyone can
### check your results. You do not need to change anything below, but make sure
### that the version of poi_id.py that you submit can be run on its own and
### generates the necessary .pkl files for validating your results.

features_list = ['poi', 'salary', 'bonus', 'communication_with_poi', 'deferral_payments', 'total_payments',
                 'loan_advances', 'restricted_stock_deferred','deferred_income', 'total_stock_value',
                 'expenses', 'exercised_stock_options', 'long_term_incentive', 'restricted_stock',
                 'director_fees']

dump_classifier_and_data(clf, my_dataset, features_list)

execfile('tester.py')