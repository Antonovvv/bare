"""
File handling module with various file operations.
"""
import os
import json
import csv
import pickle
from typing import List, Dict, Any, Optional, Union
from pathlib import Path


class FileHandler:
    """A class for handling various file operations."""
    
    def __init__(self, base_path: str = "."):
        self.base_path = Path(base_path)
    
    def read_text_file(self, filename: str) -> str:
        """Read content from a text file."""
        file_path = self.base_path / filename
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                return file.read()
        except FileNotFoundError:
            raise FileNotFoundError(f"File not found: {file_path}")
        except UnicodeDecodeError:
            raise ValueError(f"File contains invalid characters: {file_path}")
    
    def write_text_file(self, filename: str, content: str) -> None:
        """Write content to a text file."""
        file_path = self.base_path / filename
        # Create directory if it doesn't exist
        file_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(content)
    
    def append_text_file(self, filename: str, content: str) -> None:
        """Append content to a text file."""
        file_path = self.base_path / filename
        with open(file_path, 'a', encoding='utf-8') as file:
            file.write(content)
    
    def read_json_file(self, filename: str) -> Union[Dict, List]:
        """Read JSON data from a file."""
        file_path = self.base_path / filename
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                return json.load(file)
        except FileNotFoundError:
            raise FileNotFoundError(f"File not found: {file_path}")
        except json.JSONDecodeError as e:
            raise ValueError(f"Invalid JSON format: {e}")
    
    def write_json_file(self, filename: str, data: Union[Dict, List], indent: int = 2) -> None:
        """Write data to a JSON file."""
        file_path = self.base_path / filename
        file_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(file_path, 'w', encoding='utf-8') as file:
            json.dump(data, file, indent=indent, ensure_ascii=False)
    
    def read_csv_file(self, filename: str, delimiter: str = ',') -> List[Dict[str, str]]:
        """Read CSV data from a file."""
        file_path = self.base_path / filename
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                reader = csv.DictReader(file, delimiter=delimiter)
                return list(reader)
        except FileNotFoundError:
            raise FileNotFoundError(f"File not found: {file_path}")
        except csv.Error as e:
            raise ValueError(f"CSV parsing error: {e}")
    
    def write_csv_file(self, filename: str, data: List[Dict[str, Any]], fieldnames: Optional[List[str]] = None) -> None:
        """Write data to a CSV file."""
        file_path = self.base_path / filename
        file_path.parent.mkdir(parents=True, exist_ok=True)
        
        if not data:
            return
        
        if fieldnames is None:
            fieldnames = list(data[0].keys())
        
        with open(file_path, 'w', newline='', encoding='utf-8') as file:
            writer = csv.DictWriter(file, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(data)
    
    def read_pickle_file(self, filename: str) -> Any:
        """Read pickled data from a file."""
        file_path = self.base_path / filename
        try:
            with open(file_path, 'rb') as file:
                return pickle.load(file)
        except FileNotFoundError:
            raise FileNotFoundError(f"File not found: {file_path}")
        except pickle.PickleError as e:
            raise ValueError(f"Pickle error: {e}")
    
    def write_pickle_file(self, filename: str, data: Any) -> None:
        """Write data to a pickle file."""
        file_path = self.base_path / filename
        file_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(file_path, 'wb') as file:
            pickle.dump(data, file)
    
    def file_exists(self, filename: str) -> bool:
        """Check if a file exists."""
        file_path = self.base_path / filename
        return file_path.exists()
    
    def get_file_size(self, filename: str) -> int:
        """Get file size in bytes."""
        file_path = self.base_path / filename
        if not file_path.exists():
            raise FileNotFoundError(f"File not found: {file_path}")
        return file_path.stat().st_size
    
    def list_files(self, pattern: str = "*") -> List[str]:
        """List files matching a pattern."""
        return [str(f.name) for f in self.base_path.glob(pattern) if f.is_file()]
    
    def delete_file(self, filename: str) -> bool:
        """Delete a file."""
        file_path = self.base_path / filename
        try:
            file_path.unlink()
            return True
        except FileNotFoundError:
            return False
        except OSError:
            return False
    
    def create_directory(self, dirname: str) -> bool:
        """Create a directory."""
        dir_path = self.base_path / dirname
        try:
            dir_path.mkdir(parents=True, exist_ok=True)
            return True
        except OSError:
            return False
    
    def get_file_info(self, filename: str) -> Dict[str, Any]:
        """Get detailed file information."""
        file_path = self.base_path / filename
        if not file_path.exists():
            raise FileNotFoundError(f"File not found: {file_path}")
        
        stat = file_path.stat()
        return {
            "name": file_path.name,
            "size": stat.st_size,
            "created": stat.st_ctime,
            "modified": stat.st_mtime,
            "is_file": file_path.is_file(),
            "is_directory": file_path.is_dir(),
            "extension": file_path.suffix
        }


def backup_file(source: str, destination: str) -> bool:
    """Create a backup of a file."""
    try:
        with open(source, 'rb') as src, open(destination, 'wb') as dst:
            dst.write(src.read())
        return True
    except (FileNotFoundError, OSError):
        return False


def compare_files(file1: str, file2: str) -> bool:
    """Compare two files for equality."""
    try:
        with open(file1, 'rb') as f1, open(file2, 'rb') as f2:
            return f1.read() == f2.read()
    except (FileNotFoundError, OSError):
        return False


def search_in_file(filename: str, search_term: str, case_sensitive: bool = True) -> List[int]:
    """Search for a term in a file and return line numbers."""
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        
        results = []
        for i, line in enumerate(lines, 1):
            if case_sensitive:
                if search_term in line:
                    results.append(i)
            else:
                if search_term.lower() in line.lower():
                    results.append(i)
        
        return results
    except (FileNotFoundError, UnicodeDecodeError):
        return []