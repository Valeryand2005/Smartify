import json
import os

def determine_mbti(mbti_scores):
    # Вопросы по шкалам MBTI
    scale_questions = {
        'EI': [11, 12, 14, 19, 28],
        'SN': [26, 31, 32, 34],
        'TF': [13, 17, 18, 24, 27],
        'JP': [15, 20, 22, 25, 33]
    }

    # Инверсия значений, где 7 = полностью не согласен, а 1 = полностью согласен
    def invert(score): return 8 - score

    # Вопросы, где высокий балл = экстраверсия (т.е. не нужно инвертировать)
    direct_ei = {11, 12, 19, 28}
    # Остальные EI-индикаторы — инвертируем (например, q14 — "трудно начать разговор")

    mbti_type = ''

    # E/I
    ei_scores = [invert(mbti_scores[f'q{i}']) if i not in direct_ei else mbti_scores[f'q{i}'] for i in scale_questions['EI']]
    mbti_type += 'I' if sum(ei_scores) / len(ei_scores) >= 4 else 'E'

    # S/N
    sn_scores = [mbti_scores[f'q{i}'] for i in scale_questions['SN']]
    mbti_type += 'N' if sum(sn_scores) / len(sn_scores) >= 4 else 'S'

    # T/F
    tf_scores = [mbti_scores[f'q{i}'] for i in scale_questions['TF']]
    mbti_type += 'F' if sum(tf_scores) / len(tf_scores) >= 4 else 'T'

    # J/P
    jp_scores = [mbti_scores[f'q{i}'] for i in scale_questions['JP']]
    mbti_type += 'J' if sum(jp_scores) / len(jp_scores) >= 4 else 'P'

    return mbti_type

# Загружаем оригинальную базу
with open('database/dataset_career_test.json', encoding='utf-8') as f:
    data = json.load(f)

new_data = []

for item in data:
    mbti_scores = item.get('mbti_scores', {})
    mbti_type = determine_mbti(mbti_scores)
    new_item = item.copy()
    new_item['mbti_type'] = mbti_type
    if 'mbti_scores' in new_item:
        del new_item['mbti_scores']
    new_data.append(new_item)

# Сохраняем новую базу данных
output_path = 'database/dataset_with_mbti.json'
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(new_data, f, ensure_ascii=False, indent=2)

print(f'✅ Файл сохранён: {output_path}')
