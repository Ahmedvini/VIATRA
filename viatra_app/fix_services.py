#!/usr/bin/env python3
import re

# Fix health_profile_service.dart
with open('lib/services/health_profile_service.dart', 'r') as f:
    content = f.read()

# Replace json.decode(response.body) with response.data
content = re.sub(r'json\.decode\(response\.body\)', 'response.data', content)

# Write back
with open('lib/services/health_profile_service.dart', 'w') as f:
    f.write(content)

print("Fixed health_profile_service.dart")

# Fix doctor_service.dart (remove unused import)
with open('lib/services/doctor_service.dart', 'r') as f:
    lines = f.readlines()

# Remove dart:convert import
lines = [l for l in lines if "import 'dart:convert';" not in l and 'import "dart:convert";' not in l]

with open('lib/services/doctor_service.dart', 'w') as f:
    f.writelines(lines)

print("Fixed doctor_service.dart")

# Fix health_profile_provider.dart
with open('lib/providers/health_profile_provider.dart', 'r') as f:
    content = f.read()

# Fix setCacheData calls
content = re.sub(
    r'setCacheData\(\s*([^,]+),\s*([^,]+),\s*_cacheDuration\s*,',
    r'setCacheData(\1, \2, ttl: _cacheDuration,',
    content
)

with open('lib/providers/health_profile_provider.dart', 'w') as f:
    f.write(content)

print("Fixed health_profile_provider.dart")

print("\nAll fixes applied!")
