import csv
import glob
import sys
from math import sqrt

def uniroot_all(f, interval, n=100, eps=1e-4):
    """
    Python implementation similar to R's uniroot.all function.
    
    Args:
    f -- function to find roots for
    interval -- tuple of (start, end) of interval to search
    n -- number of subintervals to divide the main interval into
    eps -- tolerance for considering a value as zero
    
    Returns:
    List of roots found in the interval
    """
    a, b = interval
    dx = (b - a) / n
    roots = []
    x1 = a
    y1 = f(x1)
    for i in range(1, n+1):
        x2 = a + i * dx
        y2 = f(x2)
        if abs(y1) <= eps:
            roots.append(x1)
        elif y1 * y2 < 0:
            # Use bisection method to refine root
            while abs(x2 - x1) > eps:
                x_mid = (x1 + x2) / 2
                y_mid = f(x_mid)
                if abs(y_mid) <= eps:
                    roots.append(x_mid)
                    break
                elif y1 * y_mid < 0:
                    x2, y2 = x_mid, y_mid
                else:
                    x1, y1 = x_mid, y_mid
            else:
                roots.append((x1 + x2) / 2)
        x1, y1 = x2, y2
    return roots

def process_csv(csv_path):
    # Read CSV file
    csv_files = glob.glob(csv_path)
    if not csv_files:
        print(f"No files found matching the pattern: {csv_path}")
        sys.exit(1)

    with open(csv_files[0], 'r') as f:
        reader = csv.DictReader(f)
        data = list(reader)

    # Convert string data to float
    freq = [float(row['freq']) for row in data]
    psd_xyz = [float(row['psd_xyz']) for row in data]

    # Find peak power and frequency
    peak_power_axis = max(psd_xyz)
    peak_freq_axis = freq[psd_xyz.index(peak_power_axis)]

    # Calculate half power
    half_power_axis = peak_power_axis / sqrt(2)

    # Create interpolation function
    def interp_func(x):
        for i in range(len(freq) - 1):
            if freq[i] <= x <= freq[i+1]:
                t = (x - freq[i]) / (freq[i+1] - freq[i])
                return psd_xyz[i] + t * (psd_xyz[i+1] - psd_xyz[i])
        return None  # x is out of range

    # Function to find roots
    def root_func(x):
        return interp_func(x) - half_power_axis

    # Find roots using our uniroot_all function
    roots_axis = uniroot_all(root_func, (min(freq), max(freq)))

    # Calculate Damping Ratio
    if len(roots_axis) >= 2:
        Damping_Ratio_axis = (roots_axis[1] - roots_axis[0]) / (2 * peak_freq_axis)
        # Print result
        print(f"{Damping_Ratio_axis:.4f}")
    else:
        print("Not enough roots found to calculate Damping Ratio")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <csv_path>")
        print("Example: python script_name.py '/tmp/resonances_*.csv'")
        sys.exit(1)
    
    csv_path = sys.argv[1]
    process_csv(csv_path)