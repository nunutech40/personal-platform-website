# Edge Case Handling untuk LeetCode Dart

Dokumen ini melengkapi framework 7 kategori LeetCode: setelah input shape, state, movement, working structure, decision rule, dan complexity, selalu cek edge case.

Prinsip penting: edge case bukan selalu berarti `return 0`. Nilai return harus mengikuti arti output problem.

## Cara Memilih Return Value

Pilih return berdasarkan kontrak soal:

| Jenis output | Saat input kosong / no answer | Contoh |
|---|---:|---|
| Count / length / jumlah | `0` | jumlah island, panjang substring |
| Index tidak ditemukan | `-1` | binary search |
| Boolean | `false` | path exists, contains duplicate |
| List hasil | `[]` | two sum no answer, combinations kosong |
| Node / object tidak ada | `null` | linked list search |
| Minimum distance/path tidak ada | `-1` | shortest path blocked |
| Sum range kosong | tergantung soal, sering `0` | range sum |
| Invalid input | throw error jika memang input di luar kontrak | divide by zero |

Contoh:

```dart
if (nums.isEmpty) return 0;
```

Itu benar kalau function-nya menghitung jumlah/panjang, misalnya:

```dart
int maxProfit(List<int> prices) {
  if (prices.isEmpty) return 0;
  // ...
}
```

Tapi untuk search index, return yang lebih benar:

```dart
if (nums.isEmpty) return -1;
```

Untuk list result:

```dart
if (nums.isEmpty) return [];
```

Untuk boolean:

```dart
if (nums.isEmpty) return false;
```

## 1. Empty Input

Case:

```dart
nums = []
s = ""
grid = []
```

Bahayanya:

```dart
nums[0]
s[0]
grid[0]
```

akan error.

Handle:

```dart
if (nums.isEmpty) return 0; // jika output count/length/sum
if (s.isEmpty) return "";
if (grid.isEmpty || grid[0].isEmpty) return -1;
```

Lebih tepatnya, sesuaikan return:

```dart
// Search index
if (nums.isEmpty) return -1;

// Return list
if (nums.isEmpty) return [];

// Boolean check
if (nums.isEmpty) return false;
```

## 2. Null

Case:

```dart
root = null
head = null
```

Bahayanya:

Traversal tree/list akan akses `.left`, `.right`, atau `.next` dari null.

Handle:

```dart
if (root == null) return 0;
if (head == null) return null;
```

Tree DFS:

```dart
int maxDepth(TreeNode? root) {
  if (root == null) return 0;

  return 1 + max(
    maxDepth(root.left),
    maxDepth(root.right),
  );
}
```

## 3. Single Element

Case:

```dart
nums = [7]
target = 7
```

Bahayanya:

Two pointers, binary search, atau linked list logic bisa salah boundary.

Handle:

```dart
if (nums.length == 1) {
  return nums[0] == target ? 0 : -1;
}
```

Linked list:

```dart
if (head == null || head.next == null) return head;
```

## 4. Duplicate

Case:

```dart
nums = [1, 1, 2]
```

Bahayanya:

Backtracking bisa menghasilkan duplicate result:

```dart
[1, 2]
[1, 2]
```

Handle:

Sort + skip duplicate di level yang sama.

```dart
nums.sort();

void backtrack(int start) {
  result.add(List<int>.from(path));

  for (int i = start; i < nums.length; i++) {
    if (i > start && nums[i] == nums[i - 1]) continue;

    path.add(nums[i]);
    backtrack(i + 1);
    path.removeLast();
  }
}
```

Untuk frequency:

```dart
final freq = <int, int>{};

for (final n in nums) {
  freq[n] = (freq[n] ?? 0) + 1;
}
```

## 5. No Answer

Case:

```dart
nums = [1, 2, 3]
target = 10
```

Bahayanya:

Function tidak return apa-apa, atau return value random.

Handle:

```dart
int search(List<int> nums, int target) {
  for (int i = 0; i < nums.length; i++) {
    if (nums[i] == target) return i;
  }

  return -1;
}
```

Return default umum:

```dart
return -1;    // index/jarak tidak ditemukan
return [];    // hasil list kosong
return false; // kondisi tidak terpenuhi
return null;  // node/object tidak ditemukan
```

## 6. Blocked

Case start blocked:

```dart
grid = [
  [1, 0],
  [0, 0],
]
```

Case goal blocked:

```dart
grid = [
  [0, 0],
  [0, 1],
]
```

Bahayanya:

BFS/DFS tetap jalan padahal start/goal tidak valid.

Handle:

```dart
if (grid[0][0] == 1) return -1;
if (grid[rows - 1][cols - 1] == 1) return -1;
```

Saat cek neighbor:

```dart
if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue;
if (grid[nr][nc] == 1) continue;
if (visited[nr][nc]) continue;
```

## 7. Cycle

Case graph:

```dart
graph = {
  1: [2],
  2: [3],
  3: [1],
}
```

Bahayanya:

DFS muter terus:

```txt
1 -> 2 -> 3 -> 1 -> 2 -> ...
```

Handle:

```dart
void dfs(int node) {
  if (visited.contains(node)) return;

  visited.add(node);

  for (final next in graph[node] ?? []) {
    dfs(next);
  }
}
```

Dependency cycle:

```dart
// 0 -> 1
// 1 -> 0
```

Handle dengan 3 state:

```dart
// 0 = unvisited
// 1 = visiting
// 2 = done
bool dfs(int node) {
  if (state[node] == 1) return false;
  if (state[node] == 2) return true;

  state[node] = 1;

  for (final next in graph[node] ?? []) {
    if (!dfs(next)) return false;
  }

  state[node] = 2;
  return true;
}
```

Linked list cycle:

```dart
bool hasCycle(ListNode? head) {
  var slow = head;
  var fast = head;

  while (fast != null && fast.next != null) {
    slow = slow?.next;
    fast = fast.next?.next;

    if (slow == fast) return true;
  }

  return false;
}
```

## 8. Overflow

Case:

```dart
low = 2147483600
high = 2147483647
```

Bahayanya di bahasa fixed integer:

```dart
mid = (low + high) ~/ 2;
```

`low + high` bisa overflow.

Handle:

```dart
mid = low + ((high - low) ~/ 2);
```

Modulo besar:

```dart
const mod = 1000000007;
result = (result + value) % mod;
result = (result * value) % mod;
```

Catatan Dart: `int` di Dart VM bisa arbitrary precision, tapi kebiasaan ini tetap bagus untuk interview lintas bahasa.

## 9. Off-by-One

Case:

```dart
nums = [1, 3, 5, 7]
target = 7
```

Bahayanya:

Loop berhenti sebelum index terakhir dicek.

Salah:

```dart
while (left < right) {}
```

Handle exact binary search:

```dart
while (left <= right) {
  final mid = left + ((right - left) ~/ 2);

  if (nums[mid] == target) return mid;
  if (nums[mid] < target) left = mid + 1;
  else right = mid - 1;
}

return -1;
```

Prefix sum:

```dart
final prefix = List.filled(nums.length + 1, 0);

for (int i = 0; i < nums.length; i++) {
  prefix[i + 1] = prefix[i] + nums[i];
}

int rangeSum(int left, int right) {
  return prefix[right + 1] - prefix[left];
}
```

## 10. Negative Number

Case:

```dart
nums = [1, -1, 2, -2, 3]
target = 3
```

Bahayanya:

Sliding window bisa salah karena sum tidak selalu naik saat `right` maju.

Handle:

Kalau ada negatif, pakai prefix sum + map.

```dart
int subarraySum(List<int> nums, int k) {
  final count = <int, int>{0: 1};
  int prefix = 0;
  int result = 0;

  for (final n in nums) {
    prefix += n;
    result += count[prefix - k] ?? 0;
    count[prefix] = (count[prefix] ?? 0) + 1;
  }

  return result;
}
```

## 11. Zero

Case:

```dart
divisor = 0
```

Bahayanya:

Divide by zero.

Handle:

```dart
if (divisor == 0) {
  throw ArgumentError("divisor cannot be zero");
}
```

Case:

```dart
nums = [0, 0, 0]
target = 0
```

Bahayanya:

Counting subarray bisa undercount kalau prefix map tidak dimulai dari `{0: 1}`.

Handle:

```dart
final count = <int, int>{0: 1};
```

## 12. All Same

Case:

```dart
nums = [5, 5, 5, 5]
```

Bahayanya:

Binary search boundary bisa salah kalau duplicate tidak dipikirkan.

Handle first occurrence:

```dart
int firstOccurrence(List<int> nums, int target) {
  int left = 0;
  int right = nums.length - 1;
  int answer = -1;

  while (left <= right) {
    final mid = left + ((right - left) ~/ 2);

    if (nums[mid] >= target) {
      if (nums[mid] == target) answer = mid;
      right = mid - 1;
    } else {
      left = mid + 1;
    }
  }

  return answer;
}
```

## 13. Answer at Beginning / End

Case:

```dart
nums = [9, 1, 2, 3]
target = 9
```

Case:

```dart
nums = [1, 2, 3, 9]
target = 9
```

Bahayanya:

Loop mulai dari index 1, atau selesai sebelum index terakhir.

Handle:

```dart
for (int i = 0; i < nums.length; i++) {
  if (nums[i] == target) return i;
}
```

## 14. Disconnected Graph

Case:

```dart
graph = {
  0: [1],
  1: [0],
  2: [3],
  3: [2],
}
```

Bahayanya:

Kalau DFS mulai dari `0` saja, component `2-3` tidak pernah dicek.

Handle:

Loop semua node.

```dart
int countComponents(int n, Map<int, List<int>> graph) {
  final visited = <int>{};
  int components = 0;

  void dfs(int node) {
    if (visited.contains(node)) return;
    visited.add(node);

    for (final next in graph[node] ?? []) {
      dfs(next);
    }
  }

  for (int node = 0; node < n; node++) {
    if (!visited.contains(node)) {
      components++;
      dfs(node);
    }
  }

  return components;
}
```

## 15. Stack / Queue / Heap Empty

Case:

```dart
stack = []
queue = []
heap = []
```

Bahayanya:

```dart
stack.removeLast()
queue.removeFirst()
heap.pop()
```

akan error.

Handle:

```dart
if (stack.isNotEmpty) {
  final top = stack.removeLast();
}
```

Queue:

```dart
while (queue.isNotEmpty) {
  final node = queue.removeFirst();
}
```

Heap:

```dart
if (heap.isEmpty) return null;
```

## 16. Backtracking Lupa Undo

Case:

```dart
nums = [1, 2, 3]
```

Bahayanya:

Path kebawa ke branch lain.

Salah:

```dart
path.add(nums[i]);
backtrack(i + 1);
// lupa path.removeLast()
```

Handle:

```dart
path.add(nums[i]);
backtrack(i + 1);
path.removeLast();
```

Bahayanya kedua:

Hasil semua sama karena menyimpan reference list yang sama.

Salah:

```dart
result.add(path);
```

Handle:

```dart
result.add(List<int>.from(path));
```

## 17. Start == Goal

Case:

```dart
grid = [
  [0],
]
```

Bahayanya:

BFS return `-1` padahal sudah sampai goal.

Handle:

```dart
if (rows == 1 && cols == 1) {
  return grid[0][0] == 0 ? 1 : -1;
}
```

Atau di BFS, cek goal sejak node pertama diproses:

```dart
if (r == rows - 1 && c == cols - 1) return distance;
```

## 18. Key Map Tidak Ada

Case:

```dart
graph[node] == null
freq[x] == null
```

Bahayanya:

Null error.

Handle:

```dart
for (final next in graph[node] ?? []) {
  dfs(next);
}
```

Frequency:

```dart
freq[x] = (freq[x] ?? 0) + 1;
```

## 19. Remove Saat Kosong

Case:

```dart
path = []
```

Bahayanya:

```dart
path.removeLast()
```

saat kosong.

Handle:

Pastikan remove hanya setelah add di branch yang sama.

```dart
path.add(choice);
backtrack();
path.removeLast();
```

Kalau manual:

```dart
if (path.isNotEmpty) path.removeLast();
```

## 20. Invalid Window

Case:

```dart
s = "abba"
```

Bahayanya:

Sliding window tidak shrink cukup jauh.

Handle:

```dart
while (count[ch]! > 1) {
  final leftCh = s[left];
  count[leftCh] = count[leftCh]! - 1;
  left++;
}
```

Pakai `while`, bukan `if`, karena window bisa butuh shrink berkali-kali.

## 21. Boundary Grid

Case:

```dart
r = -1
c = cols
```

Bahayanya:

Access keluar grid.

Handle:

```dart
bool inBounds(int r, int c) {
  return r >= 0 && r < rows && c >= 0 && c < cols;
}

if (!inBounds(nr, nc)) continue;
```

## 22. Duplicate Visit di BFS

Case:

```dart
A -> B
C -> B
```

Bahayanya:

`B` masuk queue berkali-kali.

Handle:

Mark visited saat enqueue, bukan saat dequeue.

```dart
visited.add(start);
queue.add(start);

for (final next in graph[node] ?? []) {
  if (visited.contains(next)) continue;

  visited.add(next);
  queue.add(next);
}
```

## 23. Sorting Mengubah Index

Case:

```dart
nums = [3, 2, 4]
target = 6
```

Bahayanya:

Sort membuat index asli hilang.

Handle:

Simpan pasangan value-index.

```dart
final pairs = <List<int>>[];

for (int i = 0; i < nums.length; i++) {
  pairs.add([nums[i], i]);
}

pairs.sort((a, b) => a[0].compareTo(b[0]));
```

Atau pakai HashMap kalau butuh index asli:

```dart
final seen = <int, int>{};

for (int i = 0; i < nums.length; i++) {
  final need = target - nums[i];

  if (seen.containsKey(need)) {
    return [seen[need]!, i];
  }

  seen[nums[i]] = i;
}
```

## 24. Mutating Input

Case:

```dart
nums.sort();
```

Bahayanya:

Caller masih butuh urutan asli.

Handle:

Copy dulu.

```dart
final sorted = List<int>.from(nums)..sort();
```

## 25. DP Base Case

Case:

```dart
target = 0
```

Bahayanya:

DP return false padahal sum 0 selalu bisa dengan pilih kosong.

Handle:

```dart
dp[0] = true;
```

Grid DP:

```dart
dp[0][0] = 1;
```

## Checklist Final Tiap Soal

```txt
1. Input kosong/null?
2. Satu elemen?
3. Jawaban tidak ada?
4. Jawaban di awal/akhir?
5. Duplicate?
6. Negative/zero?
7. Boundary index/grid?
8. Cycle/visited?
9. Queue/stack kosong?
10. Backtracking undo?
11. Prefix/DP base case?
12. Sorting merusak index asli?
13. Return value sudah sesuai kontrak soal?
```
