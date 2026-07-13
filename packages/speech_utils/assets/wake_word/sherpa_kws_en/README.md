# Bundled English wake-word model

This is the int8 subset of
`sherpa-onnx-kws-zipformer-zh-en-3M-2025-12-20`:

- Source: https://github.com/k2-fsa/sherpa-onnx/releases/tag/kws-models
- Modeling unit: English ARPABET phonemes and Chinese pinyin
- License: Apache-2.0

The package includes the encoder, decoder, joiner, `tokens.txt`, and the
English pronunciation lexicon. `SherpaOnnxWakeWordDetector.create` extracts
these assets to a versioned runtime cache and converts plain English phrases
to phoneme keyword sequences automatically. Unknown product names use a
rule-based grapheme-to-phoneme fallback with pronunciation alternatives.
