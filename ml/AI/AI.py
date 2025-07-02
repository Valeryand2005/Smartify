import json

# === 1. Загрузка данных ===
with open("database/dataset_with_mbti_descriptions.json", "r", encoding="utf-8") as f:
    students = json.load(f)

with open("database/professions.json", "r", encoding="utf-8") as f:
    professions = json.load(f)

# === 2. Главная функция расчёта рейтинга ===
def score_profession_normalized(student, profession):
    total_score = 0
    reasons, negatives = [], []

    subj_scores = student["subject_scores"]
    required_subjects = [s.replace(" (базовый)", "").replace(" (профильный)", "").strip() for s in profession["ege_subjects"]]
    max_subj_score = len(required_subjects) * 5  # макс. балл по предметам

    # === 1) Предметы с оценками (35%) ===
    subj_sum = 0
    matched_subjects = []
    for subj in required_subjects:
        mark = subj_scores.get(subj)
        if mark:
            subj_sum += mark
            matched_subjects.append(f"{subj} ({mark})")
            if mark <= 2:
                negatives.append(f"{subj} — низкий балл ({mark})")
        else:
            negatives.append(f"{subj} — отсутствует в твоих предметах")

    if matched_subjects:
        reasons.append(f"Подходящие предметы и оценки: {', '.join(matched_subjects)}")

    subj_score_norm = (subj_sum / max_subj_score) if max_subj_score else 0
    total_score += subj_score_norm * 35

    # === 2) MBTI (20%) ===
    mbti_match = student["mbti_type"]["code"] in profession["mbti_types"].replace(" ", "").split(",")
    if mbti_match:
        reasons.append(f"Твой MBTI ({student['mbti_type']['code']}) подходит под эту профессию.")
        total_score += 20
    else:
        negatives.append(f"MBTI {student['mbti_type']['code']} может не совпадать с типичными для этой профессии.")

    # === 3) Интересы (15%) ===
    interest_match = set(student["interests"]) & set(profession.get("interests", []))
    interest_score = len(interest_match) / len(profession.get("interests", []) or [1])
    if interest_match:
        reasons.append(f"Интересы совпадают: {', '.join(interest_match)}.")
    total_score += interest_score * 15

    # === 4) Ценности (15%) ===
    value_match = set(student["values"]) & set(profession.get("values", []))
    value_score = len(value_match) / len(profession.get("values", []) or [1])
    if value_match:
        reasons.append(f"Ценности совпадают: {', '.join(value_match)}.")
    total_score += value_score * 15

    # === 5) Предпочтения роли, места, стиля (10%) ===
    pref = student["work_preferences"]
    match_count = 0
    for k in ["role", "place", "style"]:
        if profession.get(k) == pref.get(k):
            match_count += 1
            reasons.append(f"Предпочтение по {k} совпадает: {profession[k]}")
    total_score += (match_count / 3) * 10

    # === 6) Исключения: -25% за каждый конфликт ===
    for ex in pref.get("exclude", []):
        if ex in profession.get("interests", []) or ex in profession.get("role", ""):
            total_score -= 25
            negatives.append(f"Ты хочешь избежать: {ex}, но профессия это подразумевает!")

    # === 7) Ограничение итогового рейтинга ===
    total_score = max(min(total_score, 100), 0)

    return round(total_score, 2), reasons, negatives

# === 3. Запуск для одного ученика ===
student = students[4]  # Или цикл по всем

scored = []
for prof in professions:
    score, pos, neg = score_profession_normalized(student, prof)
    scored.append({
        "name": prof["name"],
        "score": score,
        "positives": pos,
        "negatives": neg,
        "desc": prof["description"]
    })

# === 4. Сортировка и топ-5 ===
scored.sort(key=lambda x: x["score"], reverse=True)
top5 = scored[:5]

# === 5. Вывод результата ===
for i, p in enumerate(top5, 1):
    print(f"\n#{i} — {p['name']} ({p['score']}%)")
    print("✅ Подходит, потому что:")
    for pos in p["positives"]:
        print(f"  - {pos}")
    if p["negatives"]:
        print("⚠️ Обрати внимание:")
        for neg in p["negatives"]:
            print(f"  - {neg}")
    print(f"📄 Описание профессии: {p['desc']}\n")
    print("-" * 60)
