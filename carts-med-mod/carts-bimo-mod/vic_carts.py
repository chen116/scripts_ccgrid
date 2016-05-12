#!/usr/bin/env python

# File: cartsFuncs.py
# Author: Geoffrey Tran gtran@isi.edu

# This file contains useful functions for interfacing with CARTS from Python. 

import xml.etree.ElementTree as ET
import xml
import copy
import subprocess
import os
import pprint
import numpy
import time
import datetime
import json
import sys
import glob
carted = 0
arg_index = 0
threshold = -1

INPUTFILE = ""
# for arg in sys.argv:
# 	if(arg=='-carted'):
# 		carted=1
# 	elif(arg_index==1):
# 		INPUTFILE = arg
# 	elif(arg_index!=0):
#  		threshold = float(arg)
# 	arg_index += 1


# from termcolor import colored

CARTS_TEMPLATE_FILE = 'template.xml'
TASKS_FILE_DIR = '../task_sets_icloud_granular/'

CARTS_INPUT_FILE = './input_carts/'
CARTS_OUTPUT_FILE = './output_carts/'
CARTS_LOCATION = 'Carts.jar'
CARTS_MODEL = "MPR"


if not os.path.exists(TASKS_FILE_DIR):
    os.makedirs(TASKS_FILE_DIR)
if not os.path.exists(CARTS_OUTPUT_FILE):
    os.makedirs(CARTS_OUTPUT_FILE)

taskset_files_names=[]
output_files_names=[]

def read_CARTS_Output():
	
	if(carted):
		os.chdir(CARTS_OUTPUT_FILE)
		for file in glob.glob("*"+INPUTFILE+"*"):
			output_files_names.append(file)
	for files in output_files_names:
		vm_required_cpus_list = []
		tree = ET.parse(files)
		root = tree.getroot()
		VMs = root.findall('component')
		vmParamDict = {}
		for index,item in enumerate(VMs):
			# print colored('Processing %s'%item.attrib['name'],'green')
			VCPU_budgets = []
			VCPU_periods = []
			VCPU_deadlines = []
			VCPU_data = item.find('processed_task')
			for index2,item2 in enumerate(VCPU_data):
				VCPU_budgets.append(item2.attrib['execution_time'])
				VCPU_periods.append(item2.attrib['period'])
				VCPU_deadlines.append(item2.attrib['deadline'])
			# print VCPU_budgets,VCPU_periods,VCPU_deadlines
			vmParamDict[item.attrib["name"]]=[VCPU_budgets,VCPU_periods,VCPU_deadlines]

		# print vmParamDict
		avg=0
		for i in range(0,len(vmParamDict['vm1'][0])):
			avg+=float(vmParamDict['vm1'][0][i])/float(vmParamDict['vm1'][1][i])
		vm_required_cpus_list.append(avg)

		print files +': ' +str(vm_required_cpus_list[0])

	# if(threshold==-1):
	# 	maxx = max(vm_required_cpus_list)
	# 	minn = min(vm_required_cpus_list)
	# 	maxx_index = [i for i, j in enumerate(vm_required_cpus_list) if j == maxx]
	# 	minn_index = [i for i, j in enumerate(vm_required_cpus_list) if j == minn]
	# 	print 'max cpus:' + str(maxx)
	# 	for index in maxx_index:
	# 		print output_files_names[index]
	# 	print 'min cpus:' + str(minn)
	# 	for index in minn_index:
	# 		print output_files_names[index]
	# else:
	# 	threshold_index = [i for i, j in enumerate(vm_required_cpus_list) if j > threshold]
	# 	print 'taskset that exceed: '+str(threshold)
	# 	for index in threshold_index:
	# 		print output_files_names[index]+" : "+str(vm_required_cpus_list[index])



def find_max_min_or_threshold_from_CARTS_output():
	if(carted):
		os.chdir(CARTS_OUTPUT_FILE)
		for file in glob.glob("*"+INPUTFILE+"*"):
		    output_files_names.append(file)
	vm_required_cpus_list = []
	for files in output_files_names:
		
	        
		with open(files) as f:
			content = f.readlines()	
		see_cpus = 0
		vm_required_cpus = -1
		if_sched = 0

		j=0
		while vm_required_cpus<0:
			if 'cpus' in content[j]:
				line = content[j]
				if see_cpus == 1:
					vm_required_cpus = int(line[13])
					if vm_required_cpus == 1:
						if line[14]!='"':
							vm_required_cpus=10+int(line[14])
					vm_required_cpus_list.append(int(vm_required_cpus))
				elif see_cpus == 0:
					if_sched = int(line[13])
				see_cpus = see_cpus+1
			j=j+1
	if(threshold==-1):
		maxx = max(vm_required_cpus_list)
		minn = min(vm_required_cpus_list)
		maxx_index = [i for i, j in enumerate(vm_required_cpus_list) if j == maxx]
		minn_index = [i for i, j in enumerate(vm_required_cpus_list) if j == minn]
		print 'max cpus:' + str(maxx)
		for index in maxx_index:
			print output_files_names[index]
		print 'min cpus:' + str(minn)
		for index in minn_index:
			print output_files_names[index]
	else:
		threshold_index = [i for i, j in enumerate(vm_required_cpus_list) if j >= threshold]
		print 'taskset that exceed: '+threshold
		for index in threshold_index:
			print output_files_names[index]+" : "+str(vm_required_cpus_list[index])


def read_tasksets(util,periods):

	# {bimo-medium/uni-light/uni-medium/uni-heavy}_{uni-moderate/uni-long}_{0.2-8.4}_{0-24}
	# util=[]
	# periods=[]

	# if(fig==1):
		# util = ["bimo-medium","uni-light","uni-medium","uni-heavy"]
		# periods = ["uni-moderate"]
	# elif(fig==4):
		# util=["bimo-medium"]
		# periods = ["uni-moderate","uni-longRTXen"]
	for ui in util:
		for pi in periods:
			util_rate = numpy.linspace(0.2,8.4,42)
			# util_rate = numpy.linspace(8.2,8.2,1)
			for ur in util_rate:
				iteration = numpy.linspace(0,24,25)
				# iteration = numpy.linspace(0,0,1)
				# processing 1 file now
				for it in iteration:
					it = int(it)
					if ur-int(ur)<0.0001:
						ur=int(ur)
					fname = ui+'_'+pi+'_'+str(ur)+'_'+str(it)
					input_taskset_file = fname
					tree = ET.parse(CARTS_TEMPLATE_FILE)
					root = tree.getroot()
					rtDict = {}
					rtDict['vm1'] = []
					component = copy.deepcopy(root[0])
			  		root.append(component)
			  		component.attrib['name'] = 'vm1'
			  		component.tag = 'component'
					with open(TASKS_FILE_DIR+fname,'r') as f:
						for line in f:
							if len(line.split())==2:
								e = line.split()[0]
								p = line.split()[1]
								rtDict['vm1'].append([e,p])
					# print rtDict

					for index,item in enumerate(rtDict['vm1']):


						task = copy.deepcopy(component[0])
						# print task
						component.append(task)
						task.attrib['e'] = str((item[0]))
						task.attrib['p'] = str((item[1]))
						task.attrib['d'] = str((item[1]))
						task.attrib['name'] = 't'+str(index)
						task.tag = "task"
						# Here, delete the first task, as it is the template
					component.remove(component.find('oldTask'))

					# Here, delete the first component, as it is the placeholder
					root.remove(root.find('oldComponent'))



					# Write to file

					tree.write(CARTS_INPUT_FILE+input_taskset_file+".xml")	
					taskset_files_names.append(input_taskset_file+".xml")	

def run_CARTS_all():
	# for the_file in os.listdir(CARTS_OUTPUT_FILE):
	# 	file_path = os.path.join(CARTS_OUTPUT_FILE, the_file)
	# 	os.unlink(file_path)


	# print "start CARTS:"
	# # print taskset_files_names
	cart_stdout = open(CARTS_OUTPUT_FILE+"/cart_stdout", 'w')
	cart_stderr = open(CARTS_OUTPUT_FILE+"/cart_stderr", 'w')


	for xml_file_name in taskset_files_names:
		ts=time.time()
		print datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')+" : "+CARTS_INPUT_FILE+xml_file_name
		if os.path.isfile(CARTS_OUTPUT_FILE+ 'out_'+xml_file_name):
			print CARTS_OUTPUT_FILE+ 'out_'+xml_file_name + " exsists"
		else:
			cart_stderr.write(xml_file_name +'\n')
			cart_stderr.flush()
			subprocess.check_call([
				"java",
				"-jar",
				CARTS_LOCATION,
				CARTS_INPUT_FILE+xml_file_name,
				CARTS_MODEL, 
				CARTS_OUTPUT_FILE+ 'out_'+xml_file_name
				],stderr = cart_stderr, stdout = cart_stdout)
			output_files_names.append(CARTS_OUTPUT_FILE+ 'out_'+xml_file_name);
			try: 
				os.remove("Ak_max.log")
				os.remove("run.log")
			except:
				print "remove Ak_max.log or run.log fail"
	cart_stdout.close()
	cart_stderr.close()
	try: 
		os.remove(CARTS_OUTPUT_FILE+"/cart_stdout")
		os.remove(CARTS_OUTPUT_FILE+"/cart_stderr")
	except:
		print "remove cart_stdout or cart_stderr fail"




if __name__ == "__main__":
	from pprint import pprint
	# util = ["bimo-medium","uni-light","uni-medium","uni-heavy"]
	util=[""]
	periods=[""]
	util[0]=(sys.argv[1])
	periods[0]=(sys.argv[2])
	if(carted==0):
		read_tasksets(util,periods)
		# carted=1
		run_CARTS_all()
		# read_CARTS_Output()

	else:
	# find_max_min_or_threshold_from_CARTS_output()

		read_CARTS_Output()

 
