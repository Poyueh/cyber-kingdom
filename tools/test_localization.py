"""Check that translated player instructions keep their variables and cover the guide."""
import json,re,unittest,tempfile
from pathlib import Path
from html.parser import HTMLParser
from build_player_guide import build
ROOT=Path(__file__).resolve().parents[1]
class GuideText(HTMLParser):
    def __init__(self):super().__init__();self.text=[]
    def handle_data(self,data):self.text.append(data)
    def handle_starttag(self,tag,attrs):
        self.text.extend(v for k,v in attrs if v and k in ('alt','aria-label','data-mobile','content'))
class LocalizationTests(unittest.TestCase):
    def test_formatted_game_text_has_all_three_translations_and_same_arguments(self):
        rows=json.loads((ROOT/'localization/game_text.gd').read_text().split('const ROWS=')[1])
        keys=set()
        for row in rows:
            self.assertNotIn(row[0],keys);keys.add(row[0]);self.assertEqual(len(row),4)
            expected=re.findall(r'%(?:\d+\$)?[dsf%]',row[0])
            for translation in row[1:]:
                self.assertTrue(translation.strip());self.assertEqual(expected,re.findall(r'%(?:\d+\$)?[dsf%]',translation),row[0])
    def test_guide_translates_visible_text_and_accessible_labels(self):
        rows=json.loads((ROOT/'docs/player-guide/translations.json').read_text())
        parser=GuideText();parser.feed((ROOT/'docs/player-guide/index.html').read_text())
        for text in parser.text:
            if re.search('[\u4e00-\u9fff]',text):
                self.assertIn(text,rows)
                self.assertTrue(rows[text]['zh_CN']);self.assertFalse(re.search('[\u4e00-\u9fff]',rows[text]['en']),text)
        for source,values in rows.items():
            for text in values.values():self.assertEqual(re.findall(r'\{\w+\}',source),re.findall(r'\{\w+\}',text))
        with tempfile.TemporaryDirectory() as folder:
            result=build(Path(folder)/'guide.html').read_text()
            self.assertNotIn('__CATALOG__',result)
            self.assertNotIn('src="guide-i18n.js"',result)
            self.assertIn('window.GuideText',result)
if __name__=='__main__':unittest.main()
