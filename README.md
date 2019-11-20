# Stat 628 module 3 
### Group Members:
Jiawei Wu, jwu424@wisc.edu\
Yansong Mao, ymao49@wisc.edu\
Zhoujingpeng Wei, zwei74@wisc.edu\
Zheng Ni, zni32@wisc.edu

### Introduction
Steak is one of the favourite food enjoyed by people in the U.S. But how to operate a popular steakhouse is a big problem. In this project, basing on yelp review dataset, we are trying to establish a comprehensive and improved rating system, in order to provide suggestions for steakhouse owners.

### Steps
- Using NLTK to clean data
- Delting attributes with a lot of missing values. And fill NA for the rest ones. Then, building Decision Tree to find useful and impactive attributes. Final suggestions are basing on these attributes.
- Finding useful dimensions used to construct rating system. Then, calculating rates for each dimension for each steakhouse. For some steakhouse without enough reviews, no rates will return.

### Shiny
- Show a location for each steakhouse in a map.
- Show a rates distribution for each steakhouse.
- Show a radar plot for each steakhouse.
- Show suggestions basing on attributes.

### Strength and Weakness
Strength: 
1. Our system provides simple, direct and powerful plots for both the steakhouse owners and potential costumers to know the strength and weakness of the steakhouses. 
2. For the rating system, we add punishment to reduce the bias produced by the two-faced reviews(contain both compliment and criticism).


Weakness:
1. Our results depend on the number of the reviews for each steakhouse. For those steakhouses who has few reviews, our system will show some biases.
2. It is hard to interpret tree method outcome objectively, which contains some subjective factors. 
3. It would be better if we can split all steakhouses into two parts: high-end restaurant and cheap restaurant.

