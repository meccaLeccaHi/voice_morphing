# voiceMorphing
#### Matlab scripts for partially-supervised morphing of voices
These scripts use the STRAIGHT toolbox for voice decomposition and transformation:

### **STRAIGHT, a speech analysis, modification and synthesis system**  
http://www.wakayama-u.ac.jp/~kawahara/STRAIGHTadv/index_e.html  

"STRAIGHT is a tool for manipulating voice quality, timbre, pitch, speed and other attributes flexibly. It is an always evolving system for attaining better sound quality, that is close to the original natural speech, by introducing advanced signal processing algorithms and findings in computational aspects of auditory processing.

STRAIGHT decomposes sounds into source information and resonator (filter) information. This conceptually simple decomposition makes it easy to conduct experiments on speech perception using STRAIGHT, the initial design objective of this tool, and to interpret experimental results in terms of huge body of classical studies."
##
### Norm-based voice space
An example voice-space generated via voice-morphing with this tool. 

![Voice-space example](http://i.imgur.com/23CJY56.png)  

#### get_STRAIGHTspectrogram.m
Uses STRAIGHT objects to create nice-looking spectrogram. 

#### SSN.m
Function to convert speech into speech-shaped noise.

#### voice_morph_images.m
Creates voice-morph stimulus space STRAIGHT voice objects and pre-assigned anchor points.  
1.  Creates average voice for all voice provided  
3. Morphs each voice identity along the radial trajectory  
4. Morph each voice identity along the tangential trajectory 
##

STRAIGHT Toolkit provided, graciously, by Hideki Kawahara, Emeritus Professor, Wakayama University
[[Bio]](http://www.wakayama-u.ac.jp/~kawahara/index_e.html)  

**Created by Dr Adam Jones  
Department of Neurosurgery,  
University of Iowa,  
Iowa City IA, USA** 
