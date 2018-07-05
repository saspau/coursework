#
# file: nyt_scraping.py
#
# description: fetches article urls from the NYTimes API
#
# usage: get_articles.py <api_key> <section_name> <num_articles>
#
# requirements: a NYTimes API key
#   available at https://developer.nytimes.com/signup
#

import requests
import json
import sys
import codecs
from math import floor
import time

ARTICLE_SEARCH_URL = 'https://api.nytimes.com/svc/search/v2/articlesearch.json'

if __name__=='__main__':
	if len(sys.argv) != 4:
		sys.stderr.write('usage: %s <api_key> <section_name> <num_articles>\n' % sys.argv[0])
		sys.exit(1)

	api_key = sys.argv[1]
	section_name = sys.argv[2]
	num_articles = sys.argv[3]

	headings = ['section_name', 'web_url', 'pub_date', 'snippet']

	f = codecs.open('test.tsv', mode='wt', encoding='utf-8')
	# f = codecs.open(section_name + '.tsv', mode='wt', encoding='utf-8')
	f.write(('\t'.join(headings)) + '\n')   

	for i in range(int(num_articles)/10):
		params = {'api-key': api_key,
				'fq': 'section_name:' + section_name,
				'page': i,
				'sort': 'newest'}
		r = requests.get(ARTICLE_SEARCH_URL, params)
		data = json.loads(r.content)

		for doc in data['response']['docs']:
			f.write('\t'.join([section_name, doc['web_url'], doc['pub_date'], doc['snippet'].encode('utf-8').replace('\n','')]) + '\n')

		time.sleep(1)

	f.close()