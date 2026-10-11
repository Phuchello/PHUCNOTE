"""Prepare isolated assets from tracked fixtures; never modify source PDFs."""
import hashlib
from pathlib import Path
import shutil

example = Path(__file__).resolve().parents[1]
source = example.parents[1] / 'fixtures' / 'document_lab'
assets = example / 'assets'
assets.mkdir(exist_ok=True)
for name in ('lecture_notes_discrete_math.pdf',
             'lecture_slides_network_security.pdf',
             'scanned_historical_notes.pdf'):
    original = source / name
    destination = assets / name
    shutil.copyfile(original, destination)
    digest = hashlib.sha256(original.read_bytes()).hexdigest()
    assert hashlib.sha256(destination.read_bytes()).hexdigest() == digest
    print(f'{name}: {original.stat().st_size} bytes SHA256={digest}')
