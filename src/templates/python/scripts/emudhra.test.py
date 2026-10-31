#!/usr/bin/env python3
"""
检查客户端是否仍信任 eMudhra 受影响中间证书。
证书错误 → 正常（已屏蔽）
连接成功 → 失败（仍信任）
"""

import sys
import ssl
import urllib.request
import urllib.error
from typing import List

# 默认测试 URL（可被命令行参数覆盖）
DEFAULT_URLS = [
  "https://dv-g3b-emudhra.we-have-a-problem.com",
  "https://dv-g3b-aaa-emudhra.we-have-a-problem.com/",
  "https://dv-g3b-noct-emudhra.we-have-a-problem.com/",
  "https://dv-g3b-aaa-noct-emudhra.we-have-a-problem.com/",
  "https://dv-g3c-emudhra.we-have-a-problem.com/",
  "https://ov-g3b-emudhra.we-have-a-problem.com/",
  "https://ov-g3c-emudhra.we-have-a-problem.com/",
  "https://ev-g3b-emudhra.we-have-a-problem.com/",
  "https://ev-g3c-emudhra.we-have-a-problem.com/",
  "https://dv-g3c-aaa-emudhra.we-have-a-problem.com/",
  "https://ov-g3b-aaa-emudhra.we-have-a-problem.com/",
  "https://ov-g3c-aaa-emudhra.we-have-a-problem.com/",
  "https://ev-g3b-aaa-emudhra.we-have-a-problem.com/",
  "https://ev-g3c-aaa-emudhra.we-have-a-problem.com/",
]

def check_url(url: str, timeout: float = 10.0) -> bool:
    """
    返回 True 表示“仍信任”（连接成功）→ 失败
    返回 False 表示“已屏蔽”（证书错误）→ 正常
    """
    ctx = ssl.create_default_context()
    # 强制校验证书
    ctx.check_hostname = True
    ctx.verify_mode = ssl.CERT_REQUIRED

    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, context=ctx, timeout=timeout) as resp:
            # 能正常拿到响应 → 仍信任
            print(f"[FAIL] {url}  → 连接成功（仍信任受影响证书）")
            return True
    except ssl.SSLCertVerificationError as e:
        print(f"[OK]   {url}  → 证书验证失败（已屏蔽）: {e.reason}")
        return False
    except ssl.SSLError as e:
        # 其他 SSL 错误也视为已屏蔽
        print(f"[OK]   {url}  → SSL 错误（已屏蔽）: {e}")
        return False
    except urllib.error.URLError as e:
        # 网络错误或证书相关
        if isinstance(e.reason, ssl.SSLError):
            print(f"[OK]   {url}  → SSL 错误（已屏蔽）: {e.reason}")
            return False
        print(f"[WARN] {url}  → 网络/其他错误: {e}")
        # 网络不通时
        return True
    except Exception as e:
        print(f"[WARN] {url}  → 未知错误: {e}")
        return True


def main(urls: List[str]) -> int:
    print("eMudhra 中间证书信任检查")
    print("=" * 60)

    still_trusted = False
    for url in urls:
        if check_url(url):
            still_trusted = True

    print("=" * 60)
    if still_trusted:
        print("结果: 仍有 URL 可成功连接 → 客户端仍信任受影响证书")
        return 1
    else:
        print("结果: 所有测试 URL 均出现证书错误 → 已正确屏蔽")
        return 0


if __name__ == "__main__":
    urls = sys.argv[1:] if len(sys.argv) > 1 else DEFAULT_URLS
    sys.exit(main(urls))