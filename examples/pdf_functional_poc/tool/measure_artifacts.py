"""Read executed traces/APKs; do not infer performance from screenshots."""
from pathlib import Path
from zipfile import ZipFile
import hashlib
import json

repo = Path(__file__).resolve().parents[3]
output = repo/'artifacts/pdf-functional-poc'
trace = json.loads((output/'acceptance-trace.json').read_text())
baseline = repo/'scratch/pdf-functional-poc/scaffold.apk'
apk = repo/'examples/pdf_functional_poc/build/app/outputs/flutter-apk/app-debug.apk'
measured = {'scaffoldDebugAPKBytes': baseline.stat().st_size,
            'pocDebugAPKBytes': apk.stat().st_size,
            'wholeExperimentAPKDeltaBytes': apk.stat().st_size-baseline.stat().st_size}
with ZipFile(baseline) as old, ZipFile(apk) as new:
    old_libraries = {n for n in old.namelist() if n.endswith('.so')}
    new_libraries = {n for n in new.namelist() if n.endswith('.so')}
    measured['newNativeLibraries'] = sorted(new_libraries-old_libraries)
    measured['unchangedCommonNativeLibraries'] = all(old.read(n)==new.read(n) for n in old_libraries&new_libraries)
    measured['pocPDFFixtures'] = [
        {'name': n, 'bytes': new.getinfo(n).file_size,
         'compressedBytes': new.getinfo(n).compress_size,
         'SHA256': hashlib.sha256(new.read(n)).hexdigest()}
        for n in new.namelist() if n.endswith('.pdf')]
    measured['documentLabPNGAssets'] = [n for n in new.namelist() if 'document_lab/renders' in n]
renders = [event for event in trace['renderingTrace'] if event['event']=='render']
opens = [event['ms'] for event in trace['renderingTrace'] if event['event']=='open']
measured['opensMs'] = opens
measured['nativeRenderMsRange'] = [min(e['nativeMs'] for e in renders),max(e['nativeMs'] for e in renders)]
measured['renderDecodeTransitionMsRange'] = [min(e['transitionMs'] for e in renders),max(e['transitionMs'] for e in renders)]
measured['observedRasterSizes'] = sorted({(e['width'],e['height']) for e in renders})
measured['snapshotMaxCacheBytes'] = max(e['cacheBytes'] for e in trace['screenshotsMetadata'])
measured['snapshotMaxCacheEntries'] = max(e['cacheEntries'] for e in trace['screenshotsMetadata'])
measured['splitDimensionsDp'] = trace['splitDimensions']
measured['screenshotDimensions'] = [(e['name'],e['physicalWidth'],e['physicalHeight']) for e in trace['screenshotsMetadata']]
(output/'measurements.json').write_text(json.dumps(measured,indent=2),encoding='utf-8')
print(json.dumps(measured,indent=2))
