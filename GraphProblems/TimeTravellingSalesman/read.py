from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import pandas as pd


pd.set_option('display.max_rows', 500)
pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 1000)


options = Options()
options.headless = True
options.binary_location = r"C:\Users\admin\AppData\Local\CocCoc\Browser\Application\browser.exe"
driver = webdriver.Chrome(chrome_options=options, executable_path=r"F:\chromedriver.exe")
driver.get("file:///D:/O.R/Julia%20Script/TimeTravellingSalesman/TimeTravellingSalesman_A.html")



html = driver.find_element_by_xpath("//*[contains(text(), 'System Test Results')]/../../..").get_attribute('outerHTML')
table = pd.read_html(html,header=0)[0].iloc[:,[1,3]].dropna(how='all').iloc[2:,:]
table.columns = ['input','output']
driver.quit()
# print(table)

table.to_excel('data.xlsx',sheet_name='Sheet1')



