import csv
import re
import json
from openpyxl import load_workbook
import os
from optparse import OptionParser

# Parse Options
parser = OptionParser()
parser.add_option("-i", "--input", dest="input", default="../project_data/Final data government finance_KB070417_DK0100718.xlsx", help="Input file", metavar="FILE")
parser.add_option("-o", "--output", dest="output", default="../output/results.csv", help="Output CSV file", metavar="FILE")
parser.add_option("-j", "--outputjson", dest="outputjson", default="../output/results.json", help="Output json file", metavar="FILE")
(options, args) = parser.parse_args()


# Temporary subset
completed_countries = [
    "Afghanistan",
    "Angola",
    "Bangladesh",
    "Benin",
    "Bhutan",
    "Bolivia",
    "Burkina Faso",
    "Burundi",
    "Cabo Verde",
    "Cambodia",
    "Central African Republic",
    "Chad",
    "Congo, Republic of",
    "DRC",
    "Eritrea",
    "Ethiopia",
    "Gambia, The",
    "Ghana",
    "Guinea",
    "Guinea-Bissau",
    "Haiti",
    "Kenya",
    "Lesotho",
    "Liberia",
    "Madagascar",
    "Malawi",
    "Mali",
    "Micronesia",
    "Mozambique",
    "Nepal",
    "Niger",
    "Nigeria",
    "Pakistan",
    "Papua New Guinea",
    "Rwanda",
    "Senegal",
    "Somalia",
    "South Sudan",
    "Sudan",
    "Tanzania",
    "Togo",
    "Uganda",
    "Zambia"
]


def float_if_possible(test_input):
    """Function that tries to float a number. IF not possible, return alphanumerics only."""
    if test_input is not None:
        try:
            output = float(test_input)
        except ValueError:
            output = re.sub(r'[^a-zA-Z0-9-_\s]', '', test_input).strip()
        return output
    return None

# Import xlsx data
dir_path = os.path.dirname(os.path.realpath(__file__))
inPath = options.input
try:
    wb = load_workbook(filename=os.path.join(dir_path, inPath), read_only=True, data_only=True)
except:
    raise Exception("Input xlsx path required!")
sheets = wb.sheetnames

# budget reference
budgetDict = {}
budgetDict["Actual"] = "actual"
budgetDict["Act"] = "actual"
budgetDict["Budget"] = "budget"
budgetDict["Est"] = "actual"
budgetDict["Estimate"] = "actual"
budgetDict["EST"] = "actual"
budgetDict["est"] = "actual"
budgetDict["Estim"] = "actual"
budgetDict["None"] = ""
budgetDict["Prel"] = "actual"
budgetDict["Prelim"] = "actual"
budgetDict["Prel Est"] = "actual"
budgetDict["Prel."] = "actual"
budgetDict["Proj"] = "proj"
budgetDict["proj"] = "proj"
budgetDict["Proj."] = "proj"
budgetDict["Prov"] = "actual"
budgetDict["Revised prog"] = "proj"
budgetDict["Projections"] = "proj"
budgetDict["Projection"] = "proj"
budgetDict["Prog"] = "proj"
budgetDict["Rev"] = "proj"
budgetDict["Staff"] = "proj"
budgetDict[""] = ""
budgetDict[None] = ""

flatData = []
hierData = {"name": "budget", "children": []}
for sheet in sheets:
    if sheet in completed_countries:
        levelDict = {}
        levelDict[1] = ""
        levelDict[2] = ""
        levelDict[3] = ""
        levelDict[4] = ""
        levelDict[5] = ""
        levelDict[6] = ""
        ws = wb[sheet]
        rowIndex = 0
        oldNames = []
        names = []
        levels = []
        years = []
        types = []
        values = []
        country = sheet
        print('Reading sheet: '+country)
        for row in ws.iter_rows():
            names.append(row[0].value)
            oldNames.append(row[1].value)
            levels.append(row[2].value)
            colLen = len(row)
            if str(row[1].value).lower() == "year":
                for i in range(3, colLen):
                    val = float_if_possible(row[i].value)
                    if str(val).lower() != 'none':
                        years.append(val)
            if str(row[1].value).lower() == "type":
                for i in range(3, colLen):
                    val = float_if_possible(row[i].value)
                    types.append(val)
            if rowIndex >= 5:
                rowValues = []
                for i in range(3, colLen):
                    val = float_if_possible(row[i].value)
                    rowValues.append(val)
                values.append(rowValues)
            rowIndex += 1
        currency = oldNames[1]
        iso = names[0]
        names = names[5:]
        levels = levels[5:]
        nameLen = len(names)
        yearLen = len(years)
        for i in range(0, nameLen):
            name = names[i]
            level = str(levels[i])
            if level.lower() != 'none':
                for j in range(0, yearLen):
                    item = {}
                    year = years[j]
                    yearType = types[j]
                    level_rank = int(level[1:2])+1
                    levelDict[level_rank] = name
                    item['iso'] = iso
                    item['country'] = country
                    item['currency'] = currency
                    item['year'] = year
                    item['type'] = budgetDict[yearType]
                    item['l1'] = levelDict[1]
                    item['l2'] = name if level_rank == 2 else levelDict[2]
                    item['l3'] = name if level_rank == 3 else levelDict[3]
                    item['l4'] = name if level_rank == 4 else levelDict[4]
                    item['l5'] = name if level_rank == 5 else levelDict[5]
                    item['l6'] = name if level_rank == 6 else ""
                    try:
                        item['value'] = values[i][j] if str(values[i][j]).lower() != 'none' else ""
                    except IndexError:
                        item['value'] = ""
                    if budgetDict[yearType] != "":
                        flatData.append(item)

print('Writing CSV...')
keys = ['country', 'iso', 'year', 'currency', 'type', 'l1', 'l2', 'l3', 'l4', 'l5', 'l6', 'value']
with open(os.path.join(dir_path, options.output), 'w') as output_file:
    dict_writer = csv.DictWriter(output_file, keys)
    dict_writer.writeheader()
    dict_writer.writerows(flatData)
print('Done.')
