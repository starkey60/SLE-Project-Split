import csv
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

data = []
with open("spotify_alltime_top100_songs.csv", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        data.append(row)

for row in data:
    row['streams'] = row.pop('total_streams_billions')

data = [{'artist': row['artist'], 'artist_country': row['artist_country'], 'streams': row['streams']} for row in data]

data = [row for row in data if str(row['artist_country']) == "UK"]

groups = {}
for row in data:
    key = row['artist']
    groups[key] = groups.get(key, 0) + float(row['streams'])
data = [{'artist': k, 'streams': v} for k, v in sorted(groups.items())]
print('GroupBy artist (sum streams):')
for _key in sorted(groups.keys()):
    print(f'  {_key}: {groups[_key]}')

if data:
    labels = [row['artist'] for row in data]
    values = [row['streams'] for row in data]
    fig, ax = plt.subplots(figsize=(max(8, len(labels) * 1.5), 6))
    bars = ax.bar(labels, values, color='#4472C4', edgecolor='#2F5597')
    for bar, val in zip(bars, values):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.03,
                f"{val:.2f}", ha='center', va='bottom', fontweight='bold')
    ax.set_xlabel('artist', fontsize=12)
    ax.set_ylabel('streams', fontsize=12)
    ax.set_title('data', fontsize=14, fontweight='bold')
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig('data_bar_proper.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Bar chart saved to data_bar.png")
else:
    print("No data to display.")