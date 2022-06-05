# In Default (Windows).sublime-keymap:
# { "keys": ["ctrl+alt+t"], "command": "insert_datetime"}
# Reference:
# https://forum.sublimetext.com/t/easiest-way-to-insert-date-time-with-a-single-keypress/4134/10
import sublime, sublime_plugin, time 

class InsertDatetimeCommand(sublime_plugin.TextCommand): 
    def run(self, edit): 
        format = "%Y/%m/%d %H:%M:%S" 
        sel = self.view.sel(); 
        for s in sel: 
            self.view.replace(edit, s, "Date: "+time.strftime(format))