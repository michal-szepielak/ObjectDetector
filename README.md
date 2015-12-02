# Object Detector

![PreviewOD](https://raw.githubusercontent.com/michal-szepielak/ObjectDetector/master/preview.png)

My first iPhone app which detects traffic polish give way sign - A7 sign. It uses [OpenCV](https://github.com/Itseez/opencv) library. 

## Sign detection method
Detection based on LBP (Local Binary Patterns) algorithm. It uses trained cascade. Cascade was trained from around 280 positive samples and 1400 negative samples.