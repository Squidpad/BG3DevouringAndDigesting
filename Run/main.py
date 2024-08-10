import os
import subprocess

def pak():
    modFolder = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    mod = "DevouringAndDigesting"
    exe = os.path.join(os.path.dirname(os.path.abspath(__file__)), "dll", "PakRun.exe")
    subprocess.check_call([exe, modFolder, mod])

def runBG3():
    import webbrowser
    path = 'steam://rungameid/1086940'
    webbrowser.open(path)

pak()
runBG3()