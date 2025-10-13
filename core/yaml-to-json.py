#!/usr/bin/env python3
"""
Simple YAML to JSON converter
Alternative to yq for systems where it's not installed
"""

import sys
import json

try:
    import yaml
except ImportError:
    print("Error: PyYAML is not installed", file=sys.stderr)
    print("Install with: pip3 install pyyaml", file=sys.stderr)
    sys.exit(1)

def yaml_to_json(yaml_file):
    """Convert YAML file to JSON"""
    try:
        with open(yaml_file, 'r', encoding='utf-8') as f:
            data = yaml.safe_load(f)
            print(json.dumps(data, ensure_ascii=False, indent=2))
            return 0
    except FileNotFoundError:
        print(f"Error: File not found: {yaml_file}", file=sys.stderr)
        return 1
    except yaml.YAMLError as e:
        print(f"Error: Invalid YAML: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: yaml-to-json.py <yaml_file>", file=sys.stderr)
        sys.exit(1)

    sys.exit(yaml_to_json(sys.argv[1]))
