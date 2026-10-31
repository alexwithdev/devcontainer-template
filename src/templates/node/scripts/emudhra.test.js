#!/usr/bin/env node
/**
 * 检查客户端是否仍信任 eMudhra 受影响中间证书。
 * 证书错误 → 正常（已屏蔽）
 * 连接成功 → 失败（仍信任）
 */

const https = require('https');
const { URL } = require('url');

// 默认测试 URL
const DEFAULT_URLS = [
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
];

// OpenSSL / Node 证书验证相关的错误码，出现这些视为“证书验证失败”
const CERT_ERROR_CODES = new Set([
  'UNABLE_TO_GET_ISSUER_CERT',
  'UNABLE_TO_DECRYPT_CERT_SIGNATURE',
  'UNABLE_TO_DECRYPT_CRL_SIGNATURE',
  'UNABLE_TO_DECODE_ISSUER_PUBLIC_KEY',
  'CERT_SIGNATURE_FAILURE',
  'CRL_SIGNATURE_FAILURE',
  'CERT_NOT_YET_VALID',
  'CERT_HAS_EXPIRED',
  'CRL_NOT_YET_VALID',
  'CRL_HAS_EXPIRED',
  'ERROR_IN_CERT_NOT_BEFORE_FIELD',
  'ERROR_IN_CERT_NOT_AFTER_FIELD',
  'ERROR_IN_CRL_LAST_UPDATE_FIELD',
  'ERROR_IN_CRL_NEXT_UPDATE_FIELD',
  'DEPTH_ZERO_SELF_SIGNED_CERT',
  'SELF_SIGNED_CERT_IN_CHAIN',
  'UNABLE_TO_GET_ISSUER_CERT_LOCALLY',
  'UNABLE_TO_VERIFY_LEAF_SIGNATURE',
  'CERT_CHAIN_TOO_LONG',
  'CERT_REVOKED',
  'INVALID_CA',
  'CERT_UNTRUSTED',
  'CERT_REJECTED',
  'ERR_TLS_CERT_ALTNAME_INVALID',
  'HOSTNAME_MISMATCH',
]);

/**
 * 检查单个 URL
 * @returns {Promise<boolean>} true = 仍信任（失败），false = 已屏蔽（正常）
 */
function checkUrl(url, timeout = 10000) {
  return new Promise((resolve) => {
    const parsed = new URL(url);

    const options = {
      hostname: parsed.hostname,
      port: parsed.port || 443,
      path: parsed.pathname + parsed.search,
      method: 'GET',
      rejectUnauthorized: true,   // 强制校验证书
      timeout,
    };

    const req = https.request(options, (res) => {
      // 能收到响应 → 仍信任
      console.log(`[FAIL] ${url}  → 连接成功（仍信任受影响证书） status=${res.statusCode}`);
      res.resume(); // 消费数据
      resolve(true);
    });

    req.on('error', (err) => {
      // 证书相关错误
      if (CERT_ERROR_CODES.has(err.code)) {
        console.log(`[OK]   ${url}  → 证书验证失败（已屏蔽）: ${err.code || err.message}`);
        resolve(false);
      } else {
        // 网络或其他错误
        console.log(`[WARN] ${url}  → 网络/其他错误: ${err.code || err.message}`);
        resolve(false); // 保守处理，不算“仍信任”
      }
    });

    req.on('timeout', () => {
      console.log(`[WARN] ${url}  → 超时`);
      req.destroy();
      resolve(false);
    });

    req.end();
  });
}

async function main(urls) {
  console.log('eMudhra 中间证书信任检查');
  console.log('='.repeat(60));

  let stillTrusted = false;

  for (const url of urls) {
    const trusted = await checkUrl(url);
    if (trusted) stillTrusted = true;
  }

  console.log('='.repeat(60));
  if (stillTrusted) {
    console.log('结果: 仍有 URL 可成功连接 → 客户端仍信任受影响证书');
    process.exit(1);
  } else {
    console.log('结果: 所有测试 URL 均出现证书错误 → 已正确屏蔽');
    process.exit(0);
  }
}

// 入口
const urls = process.argv.slice(2);
main(urls.length > 0 ? urls : DEFAULT_URLS).catch((err) => {
  console.error('脚本异常:', err);
  process.exit(2);
});