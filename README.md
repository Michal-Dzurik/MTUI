# Overview

MTIU is a Terminal User Interface framework for bash scripts. 

# Documentation 

## Loader
This view represents a loading animation, which can be stopped by finishing execution of last task.
Here is how you can implement it:

~~~sh
your_function & loader
~~~

Loader is displayed until **your_function** is finished.