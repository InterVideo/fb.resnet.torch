local extract_features = require('./pretrained/feature-extractor').extract_features

features = extract_features('pretrained/resnet-200.t7', 'data/yakovenkodenis', 1)

print(features)
