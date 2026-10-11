"""Losslessly optimize captured PNGs and compose a labelled evidence overview."""
from pathlib import Path
from PIL import Image, ImageOps, ImageDraw, ImageFont

repo = Path(__file__).resolve().parents[3]
artifacts = repo / 'artifacts/pdf-functional-poc'
names = ['01-pdf-page-1','02-pdf-page-4','03-pdf-200-percent','04-pdf-fit-width',
         '05-pdf-live-ink','06-same-ink-after-zoom','07-pdf-thumbnails',
         '08-slide-page-1','09-slide-page-6','10-split-real-slide-and-note',
         '11-portrait-reader','12-dark-atelier-reader']
sheet = Image.new('RGB',(1800,1840),'#faf7f0')
draw = ImageDraw.Draw(sheet)
font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf',20)
title = ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf',28)
draw.text((20,10),'PHUCNOTE · PDF functional POC · Android emulator captures',fill='#18324b',font=title)
for index,name in enumerate(names):
    path = artifacts/f'{name}.png'
    with Image.open(path) as captured:
        image = captured.copy()
    image.save(path,optimize=True,compress_level=9)  # Keep every original pixel.
    thumbnail = ImageOps.contain(image.convert('RGB'),(580,386))
    x,y=(index%3)*600,(index//3)*450+60
    sheet.paste(thumbnail,(x+(600-thumbnail.width)//2,y))
    draw.text((x+10,y+395),name,fill='#18324b',font=font)
sheet.save(repo/'PDF_FUNCTIONAL_POC_CONTACT_SHEET.png',optimize=True)
print('Reviewed evidence overview ready; source screenshots keep native dimensions.')
