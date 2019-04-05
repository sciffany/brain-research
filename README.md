# Research at Brain-Computer Interface Lab

For my research, I used MATLAB signal-processing and statistical toolbox to compute features (alpha-beta asymmetry ratio, alpha power, beta power, theta power) of brain EEG signals across 32 channels and five subjects and analyzed trends in these features in relation to subject's valence/arousal ratings after viewing affective [IAPS](https://en.wikipedia.org/wiki/International_Affective_Picture_System) images

## Research Submission

Please refer to the files below to see my project results:

* Read my [research paper](/All%20Submissions%20for%20Compilation/SSEF%20Submissions/SSEF%20Main%20Submission.pdf) (Note: pdf file might take a while to load)
  
* View my research poster:

![alt text](/All%20Submissions%20for%20Compilation/Poster/poster.jpg) 

## MATLAB Codes

### EEG signal extraction

[`loadeegdata.m`](/MATLAB%20codes%20(compiled)/barAlphaAsymmetry.m) – given a subject name, reads the EEG file, and generates details raw EEG data in matlab matrices

[`extract.m`](/MATLAB%20codes%20(compiled)/extract.m) – returns a segment of signals from raw EEG data, given starting time, signal length, user’s raw EEG data, and channel number, and returns a vector of time and a vector of amplitudes

### Bandpower Computation

[`generalFilter.m`](/MATLAB%20codes%20(compiled)/generalFilter.m) – returns a filtered signal after detrending and filtering a raw signal given highpass and lowpass value

[`loadPxxSubj.m`](/MATLAB%20codes%20(compiled)/loadPxxSubj.m) - calculates features of brain signals (alpha band, beta band, theta band) using high-pass and low-pass filters and pwelch.

[`loadPxxSubjPrint.m`](/MATLAB%20codes%20(compiled)/loadPxxSubjPrint.m) – plots the pwelch of a frequency band for high, medium and low levels of valence/arousal for one subject

### Feature Computation

[`getbaRatio.m`](/MATLAB%20codes%20(compiled)/getbaRatio.m) – returns the beta-alpha ratio given a signal

[`getbaRatioWBase.m`](/MATLAB%20codes%20(compiled)/getbaRatioWBase.m) – returns the beta-alpha ratio given a signal and a baseline

### Valence/Arousal Rating

[`findSubjRatings.m`](/MATLAB%20codes%20(compiled)/findSubjRatings.m) – returns a list of pictures that the subject evaluated, the valence/arousal rating of the subject, and additionally, the valence/arousal rating from IAPS, given subject based on file list provided by `loadRatings.m`

[`loadRatings.m`](/MATLAB%20codes%20(compiled)/loadRatings.m) - returns a list of files, reads the IAPS manual, and tabulates the valence/arousal ratings of all IAPS pictures 

### Trend Analysis and Classification (All subjects)

[`barAlphaAsymmetry.m`](/MATLAB%20codes%20(compiled)/barAlphaAsymmetry.m) – compares alpha asymmetry or theta asymmetry differences of 32 channels for five subjects for each valence/arousal class

[`barBandPower.m`](/MATLAB%20codes%20(compiled)/barBandPower.m) – compares signal powers (alpha, beta, theta) or beta-alpha ratio differences of 32 channels for five subjects for each valence/arousal class

[`barPower.m`](/MATLAB%20codes%20(compiled)/barPower.m) - compares average signal powers (alpha, beta, theta) or beta-alpha ratio of three categories of valence/arousal for 32 channels for five subjects for each valence/arousal class


### Trend Analysis and Classification (Single Subject)

[`trendAlphaAsym.m`](/MATLAB%20codes%20(compiled)/trendAlphaAsym.m) – plots a scatter graph of alpha asymmetry or theta asymmetry against valence/arousal rating for 1 subject

[`trendBandPower.m`](/MATLAB%20codes%20(compiled)/trendBandPower.m) – plots a scatter graph of average beta power or alpha power or theta power or beta-alpha ratio against valence/arousal rating for 1 subject`

### Others

[`loadSignals.m`](/MATLAB%20codes%20(compiled)/loadSignals.m) – plots the average segment of EEG signals of a certain frequency band averaged across all subjects in high, medium and low levels of valence/arousal
