# kkboxDemo
Environment setup
1. Install python 2.7 and pip
2. Using pip to install below package
    - pip install --upgrade robotframework
    - pip install robotframework-selenium2library
3. Put selenimu web driver to python install folder, download the broserw you want from below link.
    - https://www.seleniumhq.org/about/platforms.jsp

How to run
1. Test using user/password default in robot framework script
> robot ./testWebPlayer.robot
2. Test using specific user/password
> robot -v USER:{user} -v PW:{password} ./testWebPlayer.robot