import os
import subprocess

def pak():
    modFolder = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    mod = "DevouringAndDigesting"
    subprocess.check_call(["dll/PakRun.exe", modFolder, mod])

def runBG3():
    import webbrowser
    path = 'steam://rungameid/1086940'
    webbrowser.open(path)

pak()
runBG3()