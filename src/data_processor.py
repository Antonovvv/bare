"""
Data processing module with various data manipulation functions.
"""
from typing import List, Dict, Any, Optional, Callable
import statistics
from datetime import datetime, timedelta


class DataProcessor:
    """A class for processing various types of data."""
    
    def __init__(self):
        self.processed_count = 0
    
    def process_numbers(self, numbers: List[Union[int, float]]) -> Dict[str, Any]:
        """Process a list of numbers and return statistics."""
        if not numbers:
            return {"error": "Empty list provided"}
        
        return {
            "count": len(numbers),
            "sum": sum(numbers),
            "mean": statistics.mean(numbers),
            "median": statistics.median(numbers),
            "mode": statistics.mode(numbers) if len(numbers) > 1 else numbers[0],
            "min": min(numbers),
            "max": max(numbers),
            "range": max(numbers) - min(numbers),
            "std_dev": statistics.stdev(numbers) if len(numbers) > 1 else 0
        }
    
    def filter_data(self, data: List[Any], condition: Callable[[Any], bool]) -> List[Any]:
        """Filter data based on a condition function."""
        return [item for item in data if condition(item)]
    
    def group_by(self, data: List[Dict[str, Any]], key: str) -> Dict[Any, List[Dict[str, Any]]]:
        """Group data by a specific key."""
        grouped = {}
        for item in data:
            if key in item:
                group_key = item[key]
                if group_key not in grouped:
                    grouped[group_key] = []
                grouped[group_key].append(item)
        return grouped
    
    def sort_data(self, data: List[Any], key: Optional[Callable] = None, reverse: bool = False) -> List[Any]:
        """Sort data with optional key function."""
        return sorted(data, key=key, reverse=reverse)
    
    def remove_duplicates(self, data: List[Any]) -> List[Any]:
        """Remove duplicates while preserving order."""
        seen = set()
        result = []
        for item in data:
            if item not in seen:
                seen.add(item)
                result.append(item)
        return result
    
    def chunk_data(self, data: List[Any], chunk_size: int) -> List[List[Any]]:
        """Split data into chunks of specified size."""
        if chunk_size <= 0:
            raise ValueError("Chunk size must be positive")
        return [data[i:i + chunk_size] for i in range(0, len(data), chunk_size)]
    
    def flatten_list(self, nested_list: List[Any]) -> List[Any]:
        """Flatten a nested list."""
        result = []
        for item in nested_list:
            if isinstance(item, list):
                result.extend(self.flatten_list(item))
            else:
                result.append(item)
        return result
    
    def count_occurrences(self, data: List[Any]) -> Dict[Any, int]:
        """Count occurrences of each item in the data."""
        counts = {}
        for item in data:
            counts[item] = counts.get(item, 0) + 1
        return counts
    
    def process_with_callback(self, data: List[Any], callback: Callable[[Any], Any]) -> List[Any]:
        """Process data with a callback function."""
        self.processed_count += len(data)
        return [callback(item) for item in data]


def validate_email(email: str) -> bool:
    """Validate email format."""
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))


def validate_phone(phone: str) -> bool:
    """Validate phone number format."""
    import re
    # Remove all non-digit characters
    digits = re.sub(r'\D', '', phone)
    # Check if it's 10 digits (US format)
    return len(digits) == 10


def format_currency(amount: float, currency: str = "USD") -> str:
    """Format amount as currency."""
    if currency == "USD":
        return f"${amount:.2f}"
    elif currency == "EUR":
        return f"€{amount:.2f}"
    elif currency == "GBP":
        return f"£{amount:.2f}"
    else:
        return f"{amount:.2f} {currency}"


def parse_date(date_string: str, format_string: str = "%Y-%m-%d") -> datetime:
    """Parse date string with specified format."""
    try:
        return datetime.strptime(date_string, format_string)
    except ValueError as e:
        raise ValueError(f"Invalid date format: {e}")


def days_between_dates(date1: datetime, date2: datetime) -> int:
    """Calculate days between two dates."""
    return abs((date2 - date1).days)


def is_weekend(date: datetime) -> bool:
    """Check if a date falls on weekend."""
    return date.weekday() >= 5  # Saturday = 5, Sunday = 6


def get_business_days(start_date: datetime, end_date: datetime) -> int:
    """Calculate business days between two dates."""
    if start_date > end_date:
        start_date, end_date = end_date, start_date
    
    business_days = 0
    current_date = start_date
    
    while current_date <= end_date:
        if not is_weekend(current_date):
            business_days += 1
        current_date += timedelta(days=1)
    
    return business_days