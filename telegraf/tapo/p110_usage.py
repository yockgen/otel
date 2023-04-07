from PyP100 import PyP110

p110 = PyP110.P110("192.168.1.165", "yockgen@gmail.com", "ben781781")

p110.handshake() #Creates the cookies required for further methods
p110.login() #Sends credentials to the plug and creates AES Key and IV for further methods

#The P110 has all the same basic functions as the plugs and additionally allow for energy monitoring.
result=p110.getEnergyUsage() #Returns dict with all of the energy usage of the connected plug
print(result['result']['current_power'])
